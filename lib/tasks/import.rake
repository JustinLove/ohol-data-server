namespace :import do
  task :test => :environment do
    require 'import'
    p 'before', Life.count

    cache = "../ohol-family-trees/cache/"
    Import.load_cache(cache)

    #path = "../ohol-family-trees/cache/lifeLog_bigserver2.onehouronelife.com/2019_06June_08_Saturday.txt"
    #path = "../ohol-family-trees/cache/lifeLog_bigserver2.onehouronelife.com/2019_06June_07_Friday.txt"
    #path = "../ohol-family-trees/cache/lifeLog_server1.onehouronelife.com/2018_04April_22_Sunday.txt"
    #Import.load_log(path)

    #path = "../ohol-family-trees/cache/lifeLog_bigserver2.onehouronelife.com/2019_06June_08_Saturday_names.txt"
    #Import.load_names(path)

    p 'after', Life.count
  end
end
