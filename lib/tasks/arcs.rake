namespace :arcs do
  task :test => :environment do
    require 'import/arcs'
    p 'before', DB[:arcs].count

    cache = "../ohol-family-trees/cache/map"
    Import::Arcs.load_cache(cache)

    p 'after', DB[:arcs].count
  end

  task :update => :environment do
    require 'import/arcs'
    p 'before', DB[:arcs].count

    Import::Arcs.fetch

    p 'after', DB[:arcs].count
  end

  task :reset => :environment do
    require 'import/arcs'

    DB[:lifelog_files].where(Sequel.like(:path, "%mapLog.txt")).delete
    DB[:arcs].delete

    Import::Arcs.fetch

    p 'after', DB[:arcs].count
  end
end
