require 'ohol-family-trees/lifelog'
require 'ohol-family-trees/history'

module Import
  def self.load_dir(dir, time_range = (Time.at(0)..Time.now))
    OHOLFamilyTrees::History.new.load_dir(dir) do |path|
      p path
      if path.match('_names.txt')
        load_names(path)
      else
        load_log(path)
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

    lives.each do |life|
      if life.playerid == 2
        epoch += 1
      end
      key = key_fields(serverid, epoch, life.playerid)
      fields = {}
      if life.birth_time
        fields.merge(birth_fields(life))
      end
      if life.death_time
        fields.merge(death_fields(life))
      end
      Life.find_or_initialize_by(key).update(fields)
    end
  end

  def self.key_fields(serverid, epoch, playerid)
    return {
      :server_id => serverid,
      :epoch => epoch,
      :playerid => playerid,
    }
  end

  def self.birth_fields(life)
    return {
      :account_hash => life.hash,
      :birth_time => Time.at(life.birth_time),
      :birth_x => life.birth_coords && life.birth_coords[0],
      :birth_y => life.birth_coords && life.birth_coords[1],
      :birth_population => life.birth_population,
      :parent => life.parent == OHOLFamilyTrees::Lifelog::NoParent ? -1 : life.parent,
      :chain => life.chain,
      :gender => life.gender,
    }
  end

  def self.death_fields(life)
    return {
      :account_hash => life.hash,
      :death_time => Time.at(life.death_time),
      :death_x => life.death_coords && life.death_coords[0],
      :death_y => life.death_coords && life.death_coords[1],
      :death_population => life.death_population,
      :gender => life.gender,
      :age => life.age,
      :cause => life.cause,
      :killer => life.killer,
    }
  end

  def self.load_names(path)
    server = path.match(/lifeLog_(.*)\//)[1]
    serverid = Server.find_by_server_name(server).id
    raise "server not found" if serverid.nil?

    file = File.open(path, "r", :external_encoding => 'ASCII-8BIT')

    while namelog = OHOLFamilyTrees::Namelog.next_line(file)
      Life.where(:server_id => serverid, :playerid => namelog.playerid)
        .order("epoch desc").limit(1)
        .update(:name => namelog.name)
    end
  end
end
