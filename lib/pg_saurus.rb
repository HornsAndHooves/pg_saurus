require "pg_saurus/engine"
require "pg_saurus/errors"
require "pg_saurus/config"

# Rails engine which allows to use some PostgreSQL features:
# * Schemas.
# * Comments on columns and tables.
# * Foreign keys.
# * Partial indexes.
module PgSaurus
  extend ActiveSupport::Autoload

  autoload :Adapter
  autoload :SchemaDumper
  autoload :Tools
  autoload :Migration
  autoload :ConnectionAdapters
  autoload :CreateIndexConcurrently

  mattr_accessor :config
  self.config = PgSaurus::Config.new

  # Configure the engine.
  def self.configure
    yield(config)
  end
end
