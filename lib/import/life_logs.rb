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
    LifelogArchive = 'publicLifeLogData/'
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
      collection.each do |logs|
        p logs.server
        Raven.extra_context(:import_server => logs.server)
        load_server(logs, filesystem)
      end
      #write_servers(filesystem)
    end

    def self.write_servers(filesystem)
      servers = ServerList.new.servers
      json = ServerPresenter.response(servers)
      filesystem.write('data/servers.json', CacheControl::OneHour.merge(ContentType::Json)) do |f|
        f << JSON.generate(json)
      end
    end

    def self.load_server(logs, filesystem)
      archive_path = "#{LifelogArchive}/lifeLog_#{logs.server}"

      list = OHOLFamilyTrees::LifelogList::Logs.new(filesystem, "#{archive_path}/file_list.json", "#{LifelogArchive}/")
      p 'list files', list.files.length
      updated_files = Set.new
      list.update_from(logs) do |logfile|
        updated_files << logfile.path
      end
      p 'updated', updated_files.length
      p 'list files', list.files.length

      list.each do |logfile|
        cache_path = logfile.path
        Raven.extra_context(:logfile => cache_path)
        #p cache_path

        return unless logfile.logfile?

        if logs.has?(logfile.path)
          logfile = logs.get(logfile.path)
        end

        if updated_files.member?(logfile.path)
          p 'updated file', logfile.path
          filesystem.write(LifelogArchive + '/' + logfile.path, CacheControl::OneYear.merge(ContentType::Text)) do |archive|
            IO::copy_stream(logfile.open, archive)
          end
        end
      end

      list.checkpoint
    end
  end
end
