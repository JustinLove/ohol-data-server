require 'database_specification'

DB = if ENV['DATABASE_URL']
  Sequel.connect ENV['DATABASE_URL']
else
  ar = ActiveRecord::Base.connection_config
  Sequel.connect DatabaseSpecification.active_record(ar).url_bare
end
