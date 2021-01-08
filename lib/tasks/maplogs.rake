namespace :maplogs do
  task :test do
    require 'import/maplogs'
    cache = ENV['OHOL_FILE_CACHE'] + 'publicMapChangeData'
    output_dir = ENV['LOCAL_OUTPUT_DIR']
    Import::Maplogs.load_cache(cache, output_dir)
  end

  task :update do
    require 'import/maplogs'
    output_bucket = ENV['OUTPUT_BUCKET']
    Import::Maplogs.fetch(output_bucket)
  end

  task :timestamp_fixup_test do
    require 'import/maplogs'
    cache = ENV['OHOL_FILE_CACHE'] + 'publicMapChangeData'
    output_dir = ENV['LOCAL_OUTPUT_DIR']
    Import::Maplogs.timestamp_fixup_cache(cache, output_dir)
  end

  task :timestamp_fixup do
    require 'import/maplogs'
    output_bucket = ENV['OUTPUT_BUCKET']
    Import::Maplogs.timestamp_fixup_live(output_bucket)
  end
end
