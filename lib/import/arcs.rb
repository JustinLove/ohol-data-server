require 'ohol-family-trees/arc'
require 'ohol-family-trees/maplog_cache'
require 'ohol-family-trees/maplog_server'

module Import
  module Arcs
    def self.load_cache(cache)
      OHOLFamilyTrees::MaplogCache::Servers.new(cache).each do |logs|
        p logs.server
        Raven.extra_context(:import_server => logs.server)
        load_server(logs)
      end
    end

    def self.fetch
      OHOLFamilyTrees::MaplogServer::Servers.new.each do |logs|
        p logs.server
        Raven.extra_context(:import_server => logs.server)
        load_server(logs)
      end
    end

    def self.load_server(logs)
      logs.each do |logfile|
        cache_path = logfile.path
        Raven.extra_context(:logfile => cache_path)
        #p cache_path
        fetched_at = Time.now
        lifelog = LifelogFile.find_by_path(cache_path)
        #p [logfile.date, lifelog && lifelog.fetched_at, lifelog && logfile.date > lifelog.fetched_at]
        next if lifelog && logfile.date < lifelog.fetched_at

        p "importing #{cache_path}"
        load_log(logfile)

        if lifelog
          lifelog.update(:fetched_at => fetched_at)
        else
          LifelogFile.create(:path => cache_path, :fetched_at => fetched_at)
        end
      end
    end

    def self.load_log(logfile)
      #p "importing #{logfile.path}"

      server = logfile.server
      server_id = Server.where(:server_name => server).pluck(:id).first
      raise "server not found" if server_id.nil?

      arcs = OHOLFamilyTrees::Arc.load_log(logfile)

      arcs.each do |arc|
        fields = {
          :server_id => server_id,
          :start => Time.at(arc.s_start),
          :end => Time.at(arc.s_end),
          :seed => arc.seed,
        }
        match = fields.dup
        match.delete(:end)
        if DB[:arcs].select(1).where(match).any?
          p 'update'
          DB[:arcs].where(match).update(:end => fields[:end])
        else
          p 'insert'
          DB[:arcs].insert(fields)
        end
      end
    end
  end
end
