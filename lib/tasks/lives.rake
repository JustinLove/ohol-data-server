namespace :lives do
  task :test => [:test_logs]

  task :update => [:update_logs]

  task :test_logs do
    require 'import/life_logs'
    raise 'ERROR environment required' unless ENV['OHOL_FILE_CACHE']
    raise 'ERROR environment required' unless ENV['LOCAL_OUTPUT_DIR']
    cache = ENV['OHOL_FILE_CACHE'] + 'publicLifeLogData/'
    output_dir = ENV['LOCAL_OUTPUT_DIR']
    Import::LifeLogs.load_cache(cache, output_dir)
  end

  task :update_logs do
    require 'import/life_logs'
    raise 'ERROR environment required' unless ENV['OUTPUT_BUCKET']
    output_bucket = ENV['OUTPUT_BUCKET']
    Import::LifeLogs.fetch(output_bucket)
  end
end
