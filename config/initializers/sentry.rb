Raven.configure do |config|
  config.environments = ['production']
  unless config.environments.include?(Rails.env)
    config.dsn = nil
  end
end
