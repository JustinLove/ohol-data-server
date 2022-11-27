require 'ohol-family-trees/monument'
require 'ohol-family-trees/monument_cache'
require 'ohol-family-trees/monument_server'
require 'ohol-family-trees/filesystem_local'
require 'ohol-family-trees/filesystem_s3'
require 'ohol-family-trees/cache_control'
require 'ohol-family-trees/content_type'

module Import
  module Monuments

    Fools = DateTime.parse('Fri, 01 Apr 2022 13:00:00 +0000')..
            DateTime.parse('Sat, 02 Apr 2022 03:00:00 +0000')

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
      known = 0
      filesystem.read("data/monuments/count.txt") do |f|
        known = f.read.to_i
      end
      p "#{count} monuments now, #{known} previous"
      return if count && count <= known
      server_list = load_servers(filesystem)
      collection.each do |logfile|
        p logfile.server
        Sentry.with_scope {|scope| scope.set_extras(:logfile => logfile.server)}
        load_log(logfile, filesystem, server_list)
      end
      filesystem.write("data/monuments/count.txt", CacheControl::OneHour.merge(ContentType::Text)) do |f|
        f << count.to_s
      end
    end

    def self.load_servers(filesystem)
      server_list = []
      filesystem.read('data/servers.json') do |f|
        json = JSON.parse(f.read)
        server_list = json["data"] if json
      end
      return server_list
    end

    def self.load_log(logfile, filesystem, server_list)
      p "importing #{logfile.path}"

      server = logfile.server
      server_id = server_list.filter {|s| s["server_name"] == server}.map {|s| s["id"]}.first

      raise "server not found" if server_id.nil?

      monuments = OHOLFamilyTrees::Monument.load_log(logfile)
      #p monuments
      static = []

      monuments.each do |monument|
        next if server_id == 17 and Fools.cover? monument.date
        static << {
          :date => monument.date&.to_i,
          :x => monument.x,
          :y => monument.y,
        }
      end

      json = {:data => static.reverse}
      filesystem.write("data/monuments/#{server_id}.json", CacheControl::OneHour.merge(ContentType::Json)) do |f|
        f << JSON.generate(json)
      end
    end
  end
end
