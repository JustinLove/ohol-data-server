namespace :monuments do
  task :test => :environment do
    require 'import/monuments'
    p 'before', DB[:monuments].count

    cache = "../ohol-family-trees/cache/monuments"
    Import::Monuments.load_cache(cache)

    p 'after', DB[:monuments].count
  end

  task :update => :environment do
    require 'import/monuments'
    p 'before', DB[:monuments].count

    Import::Monuments.fetch

    p 'after', DB[:monuments].count
  end

  task :reset => :environment do
    require 'import/monuments'

    DB[:monuments].delete

    Import::Monuments.fetch

    p 'after', DB[:monuments].count
  end
end
