require 'ohol-family-trees/lifelog'
require 'ohol-family-trees/history'

module Import
  def self.load_cache(cache)
    Dir.foreach(cache) do |dir|
      next unless dir.match("lifeLog_")
      p dir
      load_dir(dir, cache)
    end
  end

  def self.load_dir(dir, cache)
    OHOLFamilyTrees::History.new.load_dir(File.join(cache, dir)) do |path|
      file_path = File.join(cache, dir, path)
      cache_path = File.join(dir, path)
      #p cache_path
      file_date = File.mtime(file_path)
      fetched_at = Time.now
      lifelog = LifelogFile.find_by_path(cache_path)
      #p [file_date, lifelog.fetched_at, file_date > lifelog.fetched_at]
      next if lifelog && file_date < lifelog.fetched_at

      p "importing #{cache_path}"
      if path.match('_names.txt')
        load_names(file_path)
      else
        load_log(file_path)
      end

      if lifelog
        lifelog.update(:fetched_at => fetched_at)
      else
        LifelogFile.create(:path => cache_path, :fetched_at => fetched_at)
      end
    end
  end

  def self.load_log(path)
    server = path.match(/lifeLog_(.*)\//)[1]
    serverid = Server.find_by_server_name(server).id
    raise "server not found" if serverid.nil?

    lives = OHOLFamilyTrees::History.new
    lives.load_log(path)

    return unless lives.length > 0

    epoch = Life.where(:server_id => serverid).where('birth_time < ?', Time.at(lives.lives.values.first.time)).maximum(:epoch) || 0

    births = []
    deaths = []
    both = []

    lives.each do |life|
      if life.playerid == 2
        epoch += 1
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
      life.killer,
    ]
  end

  def self.load_names(path)
    server = path.match(/lifeLog_(.*)\//)[1]
    serverid = Server.find_by_server_name(server).id
    raise "server not found" if serverid.nil?

    file = File.open(path, "r", :external_encoding => 'ASCII-8BIT')

    while namelog = OHOLFamilyTrees::Namelog.next_log(file)
      Life.where(:server_id => serverid, :playerid => namelog.playerid)
        .order("epoch desc").limit(1)
        .update(:name => namelog.name)
    end
  end
end
