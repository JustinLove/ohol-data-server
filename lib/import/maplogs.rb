require 'ohol-family-trees/maplog_cache'
require 'ohol-family-trees/maplog_list'
require 'ohol-family-trees/maplog_server'
require 'ohol-family-trees/object_data'
require 'ohol-family-trees/output_final_placements'
require 'ohol-family-trees/output_maplog'
require 'ohol-family-trees/seed_break'
require 'ohol-family-trees/logfile_context'
require 'ohol-family-trees/filesystem_local'
require 'ohol-family-trees/filesystem_s3'

module Import
  module Maplogs
    MaplogArchive = 'publicMapChangeData/'
    def self.load_cache(cache, output_dir)
      filesystem = OHOLFamilyTrees::FilesystemLocal.new(output_dir)
      collection = OHOLFamilyTrees::MaplogCache::Servers.new(cache)
      load_collection(collection, filesystem)
    end

    def self.fetch(output_bucket)
      filesystem = OHOLFamilyTrees::FilesystemS3.new(output_bucket)
      collection = OHOLFamilyTrees::MaplogServer::Servers.new
      load_collection(collection, filesystem)
    end

    def self.timestamp_fixup_cache(cache, output_dir)
      filesystem = OHOLFamilyTrees::FilesystemLocal.new(output_dir)
      collection = OHOLFamilyTrees::MaplogCache::Servers.new(cache)
      timestamp_fixup(collection, filesystem)
    end

    def self.timestamp_fixup_live(output_bucket)
      filesystem = OHOLFamilyTrees::FilesystemS3.new(output_bucket)
      collection = OHOLFamilyTrees::MaplogServer::Servers.new
      timestamp_fixup(collection, filesystem)
    end

    def self.load_collection(collection, filesystem)
      objects = OHOLFamilyTrees::ObjectData.new
      filesystem.read('static/objects.json') do |f|
        objects.read!(f.read)
      end

      raise "no object data" unless objects.object_size.length > 0

      collection.each do |logs|
        p logs.server
        Raven.extra_context(:import_server => logs.server)
        load_server(logs, filesystem, objects)
      end
    end

    def self.load_server(logs, filesystem, objects)
      server = logs.server.sub('/', '')
      server_id = Server.where(:server_name => server).pluck(:id).first
      raise "server not found" if server_id.nil?
      placement_path = "pl/#{server_id}"
      maplog_path = "pl/#{server_id}"

      list = OHOLFamilyTrees::MaplogList::Logs.new(filesystem, "#{placement_path}/file_list.json", MaplogArchive)
      updated_files = Set.new
      list.update_from(logs) do |logfile|
        updated_files << logfile.path
      end

      final_placements = OHOLFamilyTrees::OutputFinalPlacements.new(placement_path, filesystem, objects)

      maplog = OHOLFamilyTrees::OutputMaplog.new(maplog_path, filesystem, objects)

      manual_resets = OHOLFamilyTrees::SeedBreak.read_manual_resets(filesystem, "#{placement_path}/manual_resets.txt")
      seeds = OHOLFamilyTrees::SeedBreak.process(list, manual_resets)
      seeds.save(filesystem, "#{placement_path}/seeds.json")

      context = OHOLFamilyTrees::LogfileContext.process(seeds, list)

      list.each do |logfile|
        cache_path = logfile.path
        Raven.extra_context(:logfile => cache_path)
        #p cache_path

        next unless logfile.placements?

        if logs.has?(logfile.path)
          logfile = logs.get(logfile.path)
        end

        #next unless logfile.path.match('000seed')
        #next unless logfile.path.match('1151446675seed') # small file
        #next unless logfile.path.match('1521396640seed') # two arcs in one file
        #next unless logfile.path.match('588415882seed') # one arc with multiple start times
        #next unless logfile.path.match('2680185702seed') # multiple files one seed
        #next unless logfile.path.match('471901928seed') # bad middle start line

        if true
          if updated_files.member?(logfile.path)
            p 'updated file', logfile.path
            filesystem.write(MaplogArchive + logfile.path) do |archive|
              IO::copy_stream(logfile.open, archive)
            end
          end
        end
        if true
          final_placements.process(logfile, context[logfile.path])
        end
        if true
          maplog.process(logfile)
        end
      end

      list.checkpoint
    end

    def self.timestamp_fixup(collection, filesystem)
      objects = OHOLFamilyTrees::ObjectData.new
      collection.each do |logs|
        p logs.server
        Raven.extra_context(:import_server => logs.server)
        fixup_server(logs, filesystem, objects)
      end
    end

    def self.fixup_server(logs, filesystem, objects)
      server = logs.server.sub('/', '')
      server_id = Server.where(:server_name => server).pluck(:id).first
      raise "server not found" if server_id.nil?
      placement_path = "pl/#{server_id}"
      maplog_path = "pl/#{server_id}"

      list = OHOLFamilyTrees::MaplogList::Logs.new(filesystem, "#{placement_path}/file_list.json", MaplogArchive)
      list.update_from(logs)

      final_placements = OHOLFamilyTrees::OutputFinalPlacements.new(placement_path, filesystem, objects)

      maplog = OHOLFamilyTrees::OutputMaplog.new(maplog_path, filesystem, objects)

      list.each do |logfile|
        cache_path = logfile.path
        Raven.extra_context(:logfile => cache_path)
        #p cache_path

        next unless logfile.placements?

        #next unless logfile.path.match('000seed')
        #next unless logfile.path.match('1151446675seed') # small file
        #next unless logfile.path.match('1521396640seed') # two arcs in one file
        #next unless logfile.path.match('588415882seed') # one arc with multiple start times
        #next unless logfile.path.match('2680185702seed') # multiple files one seed
        #next unless logfile.path.match('471901928seed') # bad middle start line

        if true
          final_placements.timestamp_fixup(logfile)
        end
        if true
          maplog.timestamp_fixup(logfile)
        end
      end
    end
  end
end
