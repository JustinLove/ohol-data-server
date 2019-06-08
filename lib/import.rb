require 'ohol-family-trees/lifelog'
require 'ohol-family-trees/history'

module Import
  def self.load_dir(dir, time_range = (Time.at(0)..Time.now))
    Dir.foreach(dir) do |path|
      p path
      dateparts = path.match(/(\d{4})_(\d{2})\w+_(\d{2})/)
      next unless dateparts

      approx_log_time = Time.gm(dateparts[1], dateparts[2], dateparts[3])
      next unless time_range.cover?(approx_log_time)

      p path

      if block_given?
        yield File.join(dir, path)
      elsif path.match('_names.txt')
        load_names(File.join(dir, path))
      else
        load_log(File.join(dir, path))
      end

    end
  end

  def self.load_log(path)
    server = path.match(/lifeLog_(.*)\//)[1]
    serverid = Server.find_by_server_name(server).id
    raise "server not found" if serverid.nil?

    epoch = nil

    file = File.open(path, "r", :external_encoding => 'ASCII-8BIT')
    while line = file.gets
      log = OHOLFamilyTrees::Lifelog.create(line, epoch, server)

      if epoch.nil?
        Life.where(:server_id => serverid).where('birth_time < ?', Time.at(log.time)).maximum(:epoch) || 0
      end

      if log.kind_of?(OHOLFamilyTrees::Lifelog::Birth)
        if log.playerid == 2
          epoch += 1
          log.epoch = epoch
          #p [epoch, path]
        end
        add_birth(serverid, epoch, log)
      else
        add_death(serverid, epoch, log)
      end
    end
  end

  def self.add_birth(serverid, epoch, log)
    key = {
      :server_id => serverid,
      :epoch => log.epoch,
      :playerid => log.playerid,
    }
    fields = {
      :account_hash => log.hash,
      :birth_time => Time.at(log.time),
      :birth_x => log.coords && log.coords[0],
      :birth_y => log.coords && log.coords[1],
      :birth_population => log.population,
      :parent => log.parent == OHOLFamilyTrees::Lifelog::NoParent ? -1 : log.parent,
      :chain => log.chain,
      :gender => log.gender,
    }
    Life.find_or_initialize_by(key).update(fields)
  end

  def self.add_death(serverid, epoch, log)
    key = {
      :server_id => serverid,
      :epoch => log.epoch,
      :playerid => log.playerid,
    }
    fields = {
      :account_hash => log.hash,
      :death_time => Time.at(log.time),
      :death_x => log.coords && log.coords[0],
      :death_y => log.coords && log.coords[1],
      :death_population => log.population,
      :gender => log.gender,
      :age => log.age,
      :cause => log.cause,
      :killer => log.killer,
    }
    #p fields
    Life.find_or_initialize_by(key).update(fields)
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
