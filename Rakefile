$LOAD_PATH.unshift "./lib"

require 'sentry-ruby'

Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
end

Rake.add_rakelib 'lib/tasks'
