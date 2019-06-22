namespace :lives do
  task :test => :environment do
    require 'import/lives'
    p 'before', DB[:lives].count

    cache = "../ohol-family-trees/cache/"
    Import::Lives.load_cache(cache)

    #path = "lifeLog_bigserver2.onehouronelife.com/2019_02February_20_Wednesday.txt"
    #logfile = OHOLFamilyTrees::LifelogCache::Logfile.new(path, cache)
    #Import::Lives.load_log(logfile)

    #path = "../ohol-family-trees/cache/lifeLog_bigserver2.onehouronelife.com/2019_06June_08_Saturday_names.txt"
    #Import::Lives.load_names(path)

    p 'after', DB[:lives].count
  end

  task :update => :environment do
    require 'import/lives'
    p 'before', DB[:lives].count

    Import::Lives.fetch

    p 'after', DB[:lives].count
  end

  task :lineage => :environment do
    require 'import/lives'
    Import::Lives.set_lineage
  end

  task :patch_lineage => :environment do
    require 'import/lives'
    Import::Lives.patch_lineage
  end

  task :patch_killer => :environment do
    require 'import/lives'
    Import::Lives.patch_killer
  end
end
