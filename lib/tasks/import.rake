namespace :import do
  task :test => :environment do
    require 'import'
    p 'before', Life.count

    cache = "../ohol-family-trees/cache/"
    Import.load_cache(cache)

    #path = "../ohol-family-trees/cache/lifeLog_bigserver2.onehouronelife.com/2019_06June_08_Saturday.txt"
    #Import.load_log(path)

    #path = "../ohol-family-trees/cache/lifeLog_bigserver2.onehouronelife.com/2019_06June_08_Saturday_names.txt"
    #Import.load_names(path)

    p 'after', Life.count
  end

  task :update => :environment do
    require 'import'
    p 'before', Life.count

    Import.fetch

    p 'after', Life.count
  end

  task :lineage => :environment do
    require 'import'
    Import.set_lineage
  end
end
