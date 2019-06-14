namespace :monuments do
  task :test => :environment do
    require 'import/monuments'
    p 'before', DB[:monuments].count

    cache = "../ohol-family-trees/cache/monuments"
    Import::Monuments.load_cache(cache)

    p 'after', DB[:monuments].count
  end
end
