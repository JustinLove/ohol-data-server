namespace :import do
  task :test => :environment do
    require 'import'
    p 'before', Life.count

    cache = "../ohol-family-trees/cache/"
    Dir.foreach(cache) do |dir|
      next unless dir.match("lifeLog_")
      next if dir.match('bigserver')
      p dir
      Import.load_dir(cache+dir)
    end
    #path = "../ohol-family-trees/cache/lifeLog_bigserver2.onehouronelife.com/2019_06June_08_Saturday.txt"
    #path = "../ohol-family-trees/cache/lifeLog_bigserver2.onehouronelife.com/2019_06June_07_Friday.txt"
    #Import.load_log(path)

    #path = "../ohol-family-trees/cache/lifeLog_bigserver2.onehouronelife.com/2019_06June_08_Saturday_names.txt"
    #Import.load_names(path)

    p 'after', Life.count
  end
end
