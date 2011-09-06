require "pg_comment/version"
require 'active_support/all'

module PgComment
  extend ActiveSupport::Autoload
  autoload :Adapter
  autoload :SchemaDumper

  module ConnectionAdapters
    extend ActiveSupport::Autoload

    autoload_under 'abstract' do
      autoload :SchemaDefinitions
      autoload :SchemaStatements
    end
  end

  module Migration
    autoload :CommandRecorder, 'pg_comment/migration/command_recorder'
  end
end

require 'pg_comment/railtie' if defined?(Rails)