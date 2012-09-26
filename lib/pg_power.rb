require "pg_power/engine"
require "pg_power/errors"

# Rails engine which allows to use some PostgreSQL features:
# * Schemas.
# * Comments on columns and tables.
# * Foreign keys.
# * Partial indexes.
module PgPower
  extend ActiveSupport::Autoload

  autoload :Adapter
  autoload :SchemaDumper
  autoload :Tools
  autoload :Migration
  autoload :ConnectionAdapters
  autoload :CreateIndexConcurrently
end
