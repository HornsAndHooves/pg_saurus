require "pg_power/engine"

module PgPower
  extend ActiveSupport::Autoload

  autoload :Adapter
  autoload :SchemaDumper
  autoload :Tools
  autoload :Migration
  autoload :ConnectionAdapters
end
