require 'ohol-family-trees/monument'
require 'ohol-family-trees/monument_cache'
require 'ohol-family-trees/monument_server'

module Import
  module Monuments
    def self.load_cache(cache)
      load_collection(OHOLFamilyTrees::MonumentCache::Servers.new(cache))
    end

    def self.fetch
      load_collection(OHOLFamilyTrees::MonumentServer::Servers.new)
    end

    def self.load_collection(collection)
      count = collection.monument_count
      known = DB[:monuments].count
      p "#{count} monuments now, #{known} in db"
      return if count && count <= known
      collection.each do |logfile|
        p logfile.server
        Raven.extra_context(:logfile => logfile.server)
        load_log(logfile)
      end
    end

    def self.load_log(logfile)
      p "importing #{logfile.path}"

      server = logfile.server
      server_id = Server.where(:server_name => server).pluck(:id).first
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
