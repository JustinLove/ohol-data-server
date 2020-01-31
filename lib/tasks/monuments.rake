namespace :monuments do
  task :test => :environment do
    require 'import/monuments'
    p 'before', DB[:monuments].count

    cache = "../ohol-family-trees/cache/monuments"
    output_dir = "../ohol-family-trees/output"
    Import::Monuments.load_cache(cache, output_dir)

    p 'after', DB[:monuments].count
  end

  task :update => :environment do
    require 'import/monuments'
    p 'before', DB[:monuments].count

    output_bucket = 'wondible-com-ohol-tiles'
    Import::Monuments.fetch(output_bucket)

    p 'after', DB[:monuments].count
  end

  task :reset => :environment do
    require 'import/monuments'

    DB[:monuments].delete

    Import::Monuments.fetch

    p 'after', DB[:monuments].count
  end
end
