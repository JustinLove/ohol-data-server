require 'ohol-family-trees/lifelog'
require 'ohol-family-trees/history'

module Import
  def self.load_log(path)
    server = path.match(/lifeLog_(.*)\//)[1]
    serverid = Server.find_by_server_name(server).id
    raise "server not found" if serverid.nil?
    lives = OHOLFamilyTrees::History.new
    lives.load_log(path)
    raise "load failed" if lives.length < 1
    lives.each do |life|
      #p life
      fields = {
        :server_id => serverid,
        :epoch => life.epoch,
        :playerid => life.playerid,
        :account_hash => life.hash,
        :birth_time => life.birth_time,
        :birth_x => life.birth_coords && life.birth_coords[0],
        :birth_y => life.birth_coords && life.birth_coords[1],
        :birth_population => life.birth_population,
        :death_time => life.death_time,
        :death_x => life.death_coords && life.death_coords[0],
        :death_y => life.death_coords && life.death_coords[1],
        :death_population => life.death_population,
        :parent => life.parent == OHOLFamilyTrees::Lifelog::NoParent ? -1 : life.parent,
        :chain => life.chain,
        :gender => life.gender,
        :age => life.age,
        :cause => life.cause,
        :killer => life.killer,
      }
      #p fields
      Life.first_or_create(fields)
    end
  end

  def self.load_names(path)
    server = path.match(/lifeLog_(.*)\//)[1]
    serverid = Server.find_by_server_name(server).id
    raise "server not found" if serverid.nil?

    file = File.open(path, "r", :external_encoding => 'ASCII-8BIT')

    while line = file.gets
      namelog = OHOLFamilyTrees::Namelog.new(line)

      Life.where(:server_id => serverid, :playerid => namelog.playerid)
        .order("epoch desc").limit(1)
        .update(:name => namelog.name)
    end
  end
end
