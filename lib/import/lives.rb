require 'ohol-family-trees/lifelog'
require 'ohol-family-trees/history'
require 'ohol-family-trees/lifelog_cache'
require 'ohol-family-trees/lifelog_server'
require 'ohol-family-trees/filesystem_local'
require 'ohol-family-trees/filesystem_s3'
require 'ohol-family-trees/cache_control'
require 'ohol-family-trees/content_type'
require 'json'

module Import
  module Lives
    def self.load_cache(cache, output_dir)
      filesystem = OHOLFamilyTrees::FilesystemLocal.new(output_dir)
      collection = OHOLFamilyTrees::LifelogCache::Servers.new(cache)
      load_collection(collection, filesystem)
    end

    def self.fetch(output_bucket)
      filesystem = OHOLFamilyTrees::FilesystemS3.new(output_bucket)
      collection = OHOLFamilyTrees::LifelogServer::Servers.new
      load_collection(collection, filesystem)
    end

    def self.load_collection(collection, filesystem)
      collection.each do |logs|
        p logs.server
        Raven.extra_context(:import_server => logs.server)
        load_server(logs)
      end
      write_servers(filesystem)
      set_lineage
    end

    def self.write_servers(filesystem)
      servers = ServerList.new.servers
      json = ServerPresenter.response(servers)
      filesystem.write('data/servers.json', CacheControl::OneHour.merge(ContentType::Json)) do |f|
        f << JSON.generate(json)
      end
    end

    def self.set_lineage
      untagged = DB[:lives].where(:lineage => nil).count
      p "before: #{untagged} lives missing lineage"

      updated = DB[:lives]
        .where(:lineage => nil, :chain => 1)
        .update(:lineage => :playerid)
      p "updated #{updated} chain 1"

      updated = DB[:lives]
        .where(:lineage => nil, :chain => 2)
        .update(:lineage => :parent)
      p "updated #{updated} chain 2"

      chains = DB[:lives]
        .where(:lineage => nil)
        .where(Sequel[:chain] > 2)
        .distinct
        .select(:chain)
        .order(:chain)
        .pluck(:chain)
      c = Sequel[:c]
      p = Sequel[:p]

      chains.each do |chain|
        updated = DB.from(Sequel.as(:lives, :c), Sequel.as(:lives, :p))
          .where(
            c[:lineage] => nil,
            c[:chain] => chain,
            p[:chain] => chain-1,
            p[:server_id] => c[:server_id],
            p[:epoch] => c[:epoch],
            p[:playerid] => c[:parent]
          )
          .where(Sequel.~(p[:lineage] => nil))
          .update(:lineage => p[:lineage])
        p "updated #{updated} chain #{chain}"
      end

      untagged = DB[:lives].where(:lineage => nil).count
      p "after: #{untagged} lives missing lineage"
    end

    def self.patch_lineage
      set_lineage

      loop do
        chains = DB[:lives].where(:lineage => nil).where(Sequel[:chain] > 2).distinct.select(:chain).pluck(:chain)

        return unless chains.any?

        chain = chains.first

        updated = DB[:lives]
          .where(:lineage => nil, :chain => chain)
          .update(:lineage => :parent)
        p "updated #{updated} chain #{chain}"

        set_lineage
      end
    end

    def self.patch_killer
      updated = DB[:lives]
        .where(:killer => 0)
        .where(Sequel.like(:cause, 'killer_%'))
        .update(:killer => Sequel.lit('substring(cause from 8)::int'))
      p "updated #{updated} with killer"
      updated = DB[:lives]
        .where(:killer => 0, :cause => 'hunger')
        .update(:killer => nil)
      p "updated #{updated} without killer"
    end

    def self.load_server(logs)
      logs.each do |logfile|
        cache_path = logfile.path
        Raven.extra_context(:logfile => cache_path)
        #p cache_path
        fetched_at = Time.now
        lifelog = LifelogFile.find_by_path(cache_path)
        #p [logfile.date, lifelog.fetched_at.to_time, logfile.date > lifelog.fetched_at]
        next if lifelog && logfile.date < lifelog.fetched_at

        p "importing #{cache_path}"
        if logfile.names?
          load_names(logfile)
        else
          load_log(logfile)
        end

        if lifelog
          lifelog.update(:fetched_at => fetched_at)
        else
          LifelogFile.create(:path => cache_path, :fetched_at => fetched_at)
        end
      end
    end

    def self.load_log(logfile)
      server = logfile.server
      serverid = DB[:servers].where(:server_name => server)
        .limit(1).pluck(:id).first
      raise "server not found" if serverid.nil?

      lives = OHOLFamilyTrees::History.new
      lives.load_log(logfile)

      return unless lives.length > 0


      accounts = []
      lives.each {|life| accounts << [life.hash]}
      p "accounts: #{accounts.length}"
      Account.import ([:account_hash]),
        accounts,
        :on_duplicate_key_ignore => true

      accounts = []
      lives.each {|life| accounts << life.hash}
      account_table = DB[:accounts].where(:account_hash => accounts).select(:id, :account_hash)
      account_map = {}
      account_table.each do |row|
        account_map[row[:account_hash]] = row[:id]
      end

      epoch = Life.where(:server_id => serverid).where('birth_time < ?', Time.at(lives.lives.values.first.time)).maximum(:epoch) || 0

      p "initial epoch #{epoch}"

      births = []
      deaths = []
      both = []

      lives.each do |life|
        if life.playerid == 2
          epoch += 1
          p "epoch advanced #{epoch}"
        end
        record = [serverid, epoch, life.playerid] + common_data(life, account_map)
        if life.birth_time && life.death_time
          record += birth_data(life) + death_data(life)
          both << record
        elsif life.birth_time
          record += birth_data(life)
          births << record
        elsif life.death_time
          record += death_data(life)
          deaths << record
        end
      end

      p "deaths: #{deaths.length}"
      Life.import (key_columns + common_columns + death_columns),
        deaths,
        :on_duplicate_key_update => {
          :conflict_target => key_columns,
          :columns => death_columns,
        }
      p "both: #{both.length}"
      Life.import (key_columns + common_columns + birth_columns + death_columns),
        both, :batch_size => 1000,
        :on_duplicate_key_update => {
          :conflict_target => key_columns,
          :columns => death_columns,
        }
      p "births: #{births.length}"
      Life.import (key_columns + common_columns + birth_columns),
        births,
        :on_duplicate_key_ignore => true
    end

    def self.key_columns
      [:server_id, :epoch, :playerid]
    end

    def self.common_columns
      [:account_id, :gender]
    end

    def self.common_data(life, account_map)
      raise "no account for hash" unless account_map[life.hash]
      [account_map[life.hash], life.gender]
    end

    def self.birth_columns
      [
        :birth_time,
        :birth_x,
        :birth_y,
        :birth_population,
        :parent,
        :chain,
      ]
    end

    def self.birth_data(life)
      [
        Time.at(life.birth_time),
        life.birth_coords && life.birth_coords[0],
        life.birth_coords && life.birth_coords[1],
        life.birth_population,
        life.parentid == OHOLFamilyTrees::Lifelog::NoParent ? -1 : life.parentid,
        life.chain,
      ]
    end

    def self.death_columns
      [
        :death_time,
        :death_x,
        :death_y,
        :death_population,
        :age,
        :cause,
        :killer,
      ]
    end

    def self.death_data(life)
      [
        Time.at(life.death_time),
        life.death_coords && life.death_coords[0],
        life.death_coords && life.death_coords[1],
        life.death_population,
        life.age,
        life.cause,
        life.killerid,
      ]
    end

    def self.load_names(logfile)
      server = logfile.server
      serverid = Server.find_by_server_name(server).id
      raise "server not found" if serverid.nil?

      file = logfile.open

      namelogs = []

      while log = OHOLFamilyTrees::Namelog.next_log(file)
        namelogs << log
      end

      names = namelogs.map {|namelog| [namelog.name]}
      p "names: #{names.length}"
      Name.import ([:name]),
        names,
        :on_duplicate_key_ignore => true

      if namelogs.any? && namelogs.first.playerid < namelogs.last.playerid
        names = namelogs.map {|namelog| namelog.name}
        name_table = DB[:names].where(:name => names).select(:id, :name)
        name_map = {}
        name_table.each do |row|
          name_map[row[:name]] = row[:id]
        end
        epoch = 0
        namelogs.find do |namelog|
          epochs = Life.where(:server_id => serverid, :playerid => namelog.playerid)
            .order("epoch desc").limit(1).pluck(:epoch)
          if epochs.any?
            epoch = epochs.first
            true
          end
        end
        names = namelogs.map {|namelog|
          [serverid, epoch, namelog.playerid, name_map[namelog.name]]
        }
        Life.import (key_columns + [:name_id]),
          names,
          :on_duplicate_key_update => {
            :conflict_target => key_columns,
            :columns => [:name_id],
          }
        Life.where(:account_id => nil).delete_all
      else
        namelogs.each do |namelog|
          DB[:lives].where(:id =>
            DB[:lives]
              .where(:server_id => serverid, :playerid => namelog.playerid)
              .order(Sequel[:epoch].desc).limit(1)
              .select(:id)
          ).update(:name_id =>
            DB[:names].where(:name => namelog.name).select(:id))
        end
      end
    end

    def self.copy_names
      DB[:names].insert([:name],
        DB[:lives].where(Sequel.~(:name => nil)).select_group(:name)
      )
      DB[:lives].update(:name_id =>
        DB[:names].where(:name => Sequel[:lives][:name]).select(:id)
      )
    end

    def self.copy_accounts
      DB[:accounts].insert([:account_hash],
        DB[:lives].where(Sequel.~(:account_hash => nil)).select_group(:account_hash)
      )
      DB[:lives].update(:account_id =>
        DB[:accounts].where(:account_hash => Sequel[:lives][:account_hash]).select(:id)
      )
    end
  end
end
