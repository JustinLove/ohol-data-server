namespace :maplogs do
  task :test => :environment do
    require 'import/maplogs'
    cache = "../ohol-family-trees/cache/map"
    output_dir = "../ohol-family-trees/output"
    Import::Maplogs.load_cache(cache, output_dir)
  end

  task :update => :environment do
    require 'import/maplogs'
    output_bucket = 'wondible-com-ohol-tiles'
    Import::Maplogs.fetch(output_bucket)
  end
end
