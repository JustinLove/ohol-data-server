namespace :monuments do
  task :test do
    require 'import/monuments'
    cache = ENV['OHOL_FILE_CACHE'] + 'monuments'
    output_dir = ENV['LOCAL_OUTPUT_DIR']
    Import::Monuments.load_cache(cache, output_dir)
  end

  task :update do
    require 'import/monuments'
    output_bucket = ENV['OUTPUT_BUCKET']
    Import::Monuments.fetch(output_bucket)
  end
end
