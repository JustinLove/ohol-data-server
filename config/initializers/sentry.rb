unless Rails.env == 'production'
  Raven.configure do |config|
    config.dsn = nil
  end
end
