namespace :monuments do
  task :test do
    require 'import/monuments'
    raise 'ERROR environment required' unless ENV['OHOL_FILE_CACHE']
    raise 'ERROR environment required' unless ENV['LOCAL_OUTPUT_DIR']
    cache = ENV['OHOL_FILE_CACHE'] + 'monuments'
    output_dir = ENV['LOCAL_OUTPUT_DIR']
    Import::Monuments.load_cache(cache, output_dir)
  end

  task :update do
    require 'import/monuments'
    raise 'ERROR environment required' unless ENV['OUTPUT_BUCKET']
    output_bucket = ENV['OUTPUT_BUCKET']
    Import::Monuments.fetch(output_bucket)
  end
end
