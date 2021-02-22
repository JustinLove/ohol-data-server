require 'ohol-family-trees/monument'
require 'ohol-family-trees/monument_cache'
require 'ohol-family-trees/monument_server'
require 'ohol-family-trees/filesystem_local'
require 'ohol-family-trees/filesystem_s3'
require 'ohol-family-trees/cache_control'

module Import
  module Monuments
    def self.load_cache(cache, output_dir)
      filesystem = OHOLFamilyTrees::FilesystemLocal.new(output_dir)
      collection = OHOLFamilyTrees::MonumentCache::Servers.new(cache)
      load_collection(collection, filesystem)
    end

    def self.fetch(output_bucket)
      filesystem = OHOLFamilyTrees::FilesystemS3.new(output_bucket)
      collection = OHOLFamilyTrees::MonumentServer::Servers.new
      load_collection(collection, filesystem)
    end

    def self.load_collection(collection, filesystem)
      count = collection.monument_count
      known = DB[:monuments].count
      p "#{count} monuments now, #{known} in db"
      return if count && count <= known
      collection.each do |logfile|
        p logfile.server
        Raven.extra_context(:logfile => logfile.server)
        load_log(logfile, filesystem)
      end
    end

    def self.load_log(logfile, filesystem)
      p "importing #{logfile.path}"

      server = logfile.server
      server_id = Server.where(:server_name => server).pluck(:id).first
      raise "server not found" if server_id.nil?

      monuments = OHOLFamilyTrees::Monument.load_log(logfile)
      #p monuments
      static = []

      monuments.each do |monument|
        static << {
          :date => monument.date&.to_i,
          :x => monument.x,
          :y => monument.y,
        }
        fields = {
          :server_id => server_id,
          :date => monument.date,
          :x => monument.x,
          :y => monument.y,
        }
        next if DB[:monuments].select(1).where(fields).any?

        DB[:monuments].insert(fields)
      end

      json = {:data => static.reverse}
      filesystem.write("data/monuments/#{server_id}.json", CacheControl::OneHour) do |f|
        f << JSON.generate(json)
      end
    end
  end
end
