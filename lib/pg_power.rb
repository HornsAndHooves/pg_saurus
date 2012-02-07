require "pg_power/engine"

module PgPower
  extend ActiveSupport::Autoload

  autoload :Adapter
  autoload :SchemaDumper
  autoload :Tools
  autoload :Migration

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
