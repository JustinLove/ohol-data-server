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

  task :killfix => :environment do
    Life.where('cause LIKE ?', 'killer_%').each do |life|
      life.update(:killer => life.cause.sub('killer_', '').to_i)
    end
  end
end
