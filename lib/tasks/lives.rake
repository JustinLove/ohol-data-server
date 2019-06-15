namespace :lives do
  task :test => :environment do
    require 'import/lives'
    p 'before', Life.count

    cache = "../ohol-family-trees/cache/"
    Import::Lives.load_cache(cache)

    #path = "lifeLog_bigserver2.onehouronelife.com/2019_02February_20_Wednesday.txt"
    #logfile = OHOLFamilyTrees::LifelogCache::Logfile.new(path, cache)
    #Import::Lives.load_log(logfile)

    #path = "../ohol-family-trees/cache/lifeLog_bigserver2.onehouronelife.com/2019_06June_08_Saturday_names.txt"
    #Import::Lives.load_names(path)

    p 'after', Life.count
  end

  task :update => :environment do
    require 'import/lives'
    p 'before', Life.count

    Import::Lives.fetch

    p 'after', Life.count
  end

  task :lineage => :environment do
    require 'import/lives'
    Import::Lives.set_lineage
  end
end
