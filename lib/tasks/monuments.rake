namespace :monuments do
  task :test => :environment do
    require 'import/monuments'
    p 'before', DB[:monuments].count

    cache = ENV['OHOL_FILE_CACHE'] + 'monuments'
    output_dir = ENV['LOCAL_OUTPUT_DIR']
    Import::Monuments.load_cache(cache, output_dir)

    p 'after', DB[:monuments].count
  end

  task :update => :environment do
    require 'import/monuments'
    p 'before', DB[:monuments].count

    output_bucket = ENV['OUTPUT_BUCKET']
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
