require "pg_power/engine"

# Rails engine which allows to use some PostgreSQL features:
# * Schemas.
# * Comments on columns and tables.
# * Foreign keys.
module PgPower
  extend ActiveSupport::Autoload

  autoload :Adapter
  autoload :SchemaDumper
  autoload :Tools
  autoload :Migration
  autoload :ConnectionAdapters
end
