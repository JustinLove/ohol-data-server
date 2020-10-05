namespace :lives do
  task :test => :environment do
    require 'import/lives'
    p 'before', DB[:lives].count

    cache = ENV['OHOL_FILE_CACHE']
    output_dir = ENV['LOCAL_OUTPUT_DIR']
    Import::Lives.load_cache(cache, output_dir)

    #path = "lifeLog_bigserver2.onehouronelife.com/2019_02February_20_Wednesday.txt"
    #logfile = OHOLFamilyTrees::LifelogCache::Logfile.new(path, cache)
    #Import::Lives.load_log(logfile)

    #path = "lifeLog_bigserver2.onehouronelife.com/2019_06June_08_Saturday_names.txt"
    #logfile = OHOLFamilyTrees::LifelogCache::Logfile.new(path, cache)
    #Import::Lives.load_names(logfile)

    p 'after', DB[:lives].count
  end

  task :update => :environment do
    require 'import/lives'
    p 'before', DB[:lives].count

    output_bucket = ENV['OUTPUT_BUCKET']
    Import::Lives.fetch(output_bucket)

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

  task :copy_names => :environment do
    require 'import/lives'
    Import::Lives.copy_names
  end

  task :copy_accounts => :environment do
    require 'import/lives'
    Import::Lives.copy_accounts
  end
end
