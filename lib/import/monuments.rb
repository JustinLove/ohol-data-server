require 'ohol-family-trees/monument'
require 'ohol-family-trees/monument_cache'
require 'ohol-family-trees/monument_server'

module Import
  module Monuments
    def self.load_cache(cache)
      OHOLFamilyTrees::MonumentCache::Servers.new(cache).each do |logfile|
        p logfile.server
        load_log(logfile)
      end
    end

    def self.fetch
      OHOLFamilyTrees::MonumentServer::Servers.new.each do |logfile|
        p logfile.server
        load_log(logfile)
      end
    end

    def self.load_log(logfile)
      p "importing #{logfile.path}"

      server = logfile.server
      server_id = Server.find_by_server_name(server).id
      raise "server not found" if server_id.nil?

      monuments = OHOLFamilyTrees::Monument.load_log(logfile)
      #p monuments

      monuments.each do |monument|
        fields = {
          :server_id => server_id,
          :date => monument.date,
          :x => monument.x,
          :y => monument.y,
        }
        next if DB[:monuments].select(1).where(fields).any?

        DB[:monuments].insert(fields)
      end
    end
  end
end
