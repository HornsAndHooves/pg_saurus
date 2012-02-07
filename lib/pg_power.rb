require "pg_power/engine"
require 'pg_power/tools'
require 'pg_power/schema/schema_statements'
require 'pg_power/migration/command_recorder'
require 'pg_power/schema_dumper'

module PgPower
  extend ActiveSupport::Autoload
  autoload :Adapter
  autoload :SchemaDumper
  autoload :Tools

  module ConnectionAdapters
    extend ActiveSupport::Autoload

    autoload_under 'abstract' do
      autoload :SchemaDefinitions
      autoload :SchemaStatements
    end
  end

  module Migration
    extend ActiveSupport::Autoload
    autoload :CommandRecorder
  end
end
