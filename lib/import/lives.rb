require 'ohol-family-trees/lifelog'
require 'ohol-family-trees/history'
require 'ohol-family-trees/lifelog_cache'
require 'ohol-family-trees/lifelog_server'

module Import
  module Lives
    def self.load_cache(cache)
      OHOLFamilyTrees::LifelogCache::Servers.new(cache).each do |logs|
        p logs.server
        Raven.extra_context(:import_server => logs.server)
        load_server(logs)
      end
      set_lineage
    end

    def self.fetch
      OHOLFamilyTrees::LifelogServer::Servers.new.each do |logs|
        p logs.server
        Raven.extra_context(:import_server => logs.server)
        load_server(logs)
      end
      set_lineage
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

      chains = DB[:lives].where(:lineage => nil).where(Sequel[:chain] > 2).distinct.select(:chain).pluck(:chain)
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
        #p [logfile.date, lifelog.fetched_at, logfile.date > lifelog.fetched_at]
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
        record = [serverid, epoch, life.playerid] + common_data(life)
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
      [:account_hash, :gender]
    end

    def self.common_data(life)
      [life.hash, life.gender]
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

      if namelogs.any? && namelogs.first.playerid < namelogs.last.playerid
        epoch = 0
        namelogs.find do |namelog|
          epochs = Life.where(:server_id => serverid, :playerid => namelog.playerid)
            .order("epoch desc").limit(1).pluck(:epoch)
          if epochs.any?
            epoch = epochs.first
            true
          end
        end
        names = namelogs.map {|namelog| [serverid, epoch, namelog.playerid, 'nameonly', namelog.name]}
        p "names: #{names.length}"
        Life.import (key_columns + [:account_hash, :name]),
          names,
          :on_duplicate_key_update => {
            :conflict_target => key_columns,
            :columns => [:name],
          }
        Life.where(:account_hash => 'nameonly').delete_all
      else
        namelogs.each do |namelog|
          Life.where(:server_id => serverid, :playerid => namelog.playerid)
            .order("epoch desc").limit(1)
            .update(:name => namelog.name)
        end
      end
    end
  end
end
