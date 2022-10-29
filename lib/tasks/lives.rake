namespace :lives do
  task :test => [:test_logs, :test_records]

  task :update => [:update_logs, :update_records]

  task :test_logs do
    require 'import/life_logs'
    cache = ENV['OHOL_FILE_CACHE'] + 'publicLifeLogData/'
    output_dir = ENV['LOCAL_OUTPUT_DIR']
    Import::LifeLogs.load_cache(cache, output_dir)
  end

  task :update_logs do
    require 'import/life_logs'
    output_bucket = ENV['OUTPUT_BUCKET']
    Import::LifeLogs.fetch(output_bucket)
  end

  task :test_records => :environment do
    require 'import/life_records'
    p 'before', DB[:lives].count

    cache = ENV['OHOL_FILE_CACHE'] + 'publicLifeLogData/'
    output_dir = ENV['LOCAL_OUTPUT_DIR']
    Import::LifeRecords.load_cache(cache, output_dir)

    #path = "lifeLog_bigserver2.onehouronelife.com/2019_02February_20_Wednesday.txt"
    #logfile = OHOLFamilyTrees::LifelogCache::Logfile.new(path, cache)
    #Import::LifeRecords.load_log(logfile)

    #path = "lifeLog_bigserver2.onehouronelife.com/2019_06June_08_Saturday_names.txt"
    #logfile = OHOLFamilyTrees::LifelogCache::Logfile.new(path, cache)
    #Import::LifeRecords.load_names(logfile)

    p 'after', DB[:lives].count
  end

  task :update_records => :environment do
    require 'import/life_records'
    p 'before', DB[:lives].count

    output_bucket = ENV['OUTPUT_BUCKET']
    Import::LifeRecords.fetch(output_bucket)

    p 'after', DB[:lives].count
  end

  task :lineage => :environment do
    require 'import/life_records'
    Import::LifeRecords.set_lineage
  end

  task :patch_lineage => :environment do
    require 'import/life_records'
    Import::LifeRecords.patch_lineage
  end

  task :patch_killer => :environment do
    require 'import/life_records'
    Import::LifeRecords.patch_killer
  end

  task :copy_names => :environment do
    require 'import/life_records'
    Import::LifeRecords.copy_names
  end

  task :copy_accounts => :environment do
    require 'import/life_records'
    Import::LifeRecords.copy_accounts
  end
end
