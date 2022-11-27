require 'ohol-family-trees/lifelog_cache'
require 'ohol-family-trees/lifelog_server'
require 'ohol-family-trees/lifelog_list'
require 'ohol-family-trees/filesystem_local'
require 'ohol-family-trees/filesystem_s3'
require 'ohol-family-trees/cache_control'
require 'ohol-family-trees/content_type'
require 'set'
require 'json'

module Import
  module LifeLogs
    LifelogArchive = 'publicLifeLogData'
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
      server_list = load_servers(filesystem)
      collection.each do |logs|
        p logs.server
        Raven.extra_context(:import_server => logs.server)
        load_server(logs, filesystem, server_list)
      end
      write_servers(filesystem, server_list)
    end

    def self.load_servers(filesystem)
      server_list = []
      filesystem.read('data/servers.json') do |f|
        json = JSON.parse(f.read)
        server_list = json["data"] if json
      end
      return server_list
    end

    def self.write_servers(filesystem, server_list)
      json = {"data" => server_list}
      filesystem.write('data/servers.json', CacheControl::OneHour.merge(ContentType::Json)) do |f|
        f << JSON.generate(json)
      end
    end

    def self.load_server(logs, filesystem, server_list)
      archive_path = "#{LifelogArchive}/lifeLog_#{logs.server}"

      list = OHOLFamilyTrees::LifelogList::Logs.new(filesystem, "#{archive_path}/file_list.json", "#{LifelogArchive}/")
      #p 'list files', list.files.length
      updated_files = Set.new
      list.update_from(logs) do |logfile|
        updated_files << logfile.path
      end
      p ['updated', updated_files.length]
      #p 'list files', list.files.length

      file_min = 0
      file_max = 0

      list.each do |logfile|
        cache_path = logfile.path
        Raven.extra_context(:logfile => cache_path)
        #p cache_path

        next unless logfile.logfile?

        if logs.has?(logfile.path)
          logfile = logs.get(logfile.path)
        end

        date = logfile.approx_log_time
        file_min = date if file_min == 0 || date < file_min
        file_max = date if date > file_max

        if updated_files.member?(logfile.path)
          if logfile.file_probably_complete?
            #p 'updated file', logfile.path
            filesystem.write(LifelogArchive + '/' + logfile.path, CacheControl::OneYear.merge(ContentType::Text)) do |archive|
              IO::copy_stream(logfile.open, archive)
            end
          end
        end
      end

      file_max += 24*60*60
      p [file_min.to_i, file_max.to_i]

      server_list.each do |server|
        if logs.server == server["server_name"]
          server["min_time"] = file_min.to_i
          server["max_time"] = file_max.to_i
        end
      end

      list.checkpoint
    end
  end
end
