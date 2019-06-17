module OholDataServer
  class Application
    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc
  end
end

Sequel.default_timezone = :utc
