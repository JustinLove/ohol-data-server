namespace :maplogs do
  task :test => :environment do
    require 'import/maplogs'
    cache = ENV['OHOL_FILE_CACHE'] + 'map'
    output_dir = ENV['LOCAL_OUTPUT_DIR']
    Import::Maplogs.load_cache(cache, output_dir)
  end

  task :update => :environment do
    require 'import/maplogs'
    output_bucket = ENV['OUTPUT_BUCKET']
    Import::Maplogs.fetch(output_bucket)
  end
end
