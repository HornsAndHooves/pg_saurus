module PgPower
  # Provides utility methods to work with PostgreSQL databases.
  # Usage:
  #   PgPower::Tools.create_schema "services"  # => create new PG schema "services"
  #   PgPower::Tools.create_schema "nets"
  #   PgPower::Tools.drop_schema "services"    # => remove the schema
  #   PgPower::Tools.schemas                   # => ["public", "information_schema", "nets"]
  module Tools
    extend self

    # Creates PostgreSQL schema
    def create_schema(schema_name)
      sql = %{CREATE SCHEMA "#{schema_name}"}
      ActiveRecord::Base.connection.execute sql
    end

    # Drops PostgreSQL schema
    def drop_schema(schema_name)
      sql = %{DROP SCHEMA "#{schema_name}"}
      ActiveRecord::Base.connection.execute sql
    end

    # Returns an array of existing schemas.
    def schemas
      sql = "SELECT nspname FROM pg_namespace WHERE nspname !~ '^pg_.*' order by nspname"
      ActiveRecord::Base.connection.query(sql).flatten
    end

  end
end
