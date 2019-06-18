# also initializers/time_zone

module DB
  def self.[](table)
    db[table]
  end

  def self.db
    @@db ||= create_db
  end

  def self.create_db
    if ENV['DATABASE_URL']
      Sequel.connect ENV['DATABASE_URL']
    else
      require 'database_specification'
      ar = ActiveRecord::Base.connection_config
      Sequel.connect DatabaseSpecification.active_record(ar).url_bare
    end.tap do |d|
      if Rails.env == 'development'
        d.loggers << Rails.logger #Logger.new($stdout)
      end
    end
  end
end
