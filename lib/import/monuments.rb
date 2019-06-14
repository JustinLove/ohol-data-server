require 'ohol-family-trees/monument'
require 'ohol-family-trees/monument_cache'

module Import
  module Monuments
    class Monument < ApplicationRecord
    end

    def self.load_cache(cache)
      OHOLFamilyTrees::MonumentCache::Servers.new(cache).each do |logfile|
        p logfile.server
        load_log(logfile)
      end
    end

    def self.load_log(logfile)
      cache_path = logfile.path
      #p cache_path
      fetched_at = Time.now
      lifelog = LifelogFile.find_by_path(cache_path)
      #p [logfile.date, lifelog.fetched_at, logfile.date > lifelog.fetched_at]
      return if lifelog && logfile.date < lifelog.fetched_at

      p "importing #{cache_path}"

      server = logfile.server
      server_id = Server.find_by_server_name(server).id
      raise "server not found" if server_id.nil?

      monuments = OHOLFamilyTrees::Monument.load_log(logfile)
      #p monuments

      records = []
      monuments.each do |monument|
        records << [server_id, monument.date, monument.x, monument.y]
      end

      Monument.import [:server_id, :date, :x, :y],
        records,
        :on_duplicate_key_ignore => true

      if lifelog
        lifelog.update(:fetched_at => fetched_at)
      else
        LifelogFile.create(:path => cache_path, :fetched_at => fetched_at)
      end
    end
  end
end
