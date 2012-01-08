module PgPower
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
      sql = "SELECT nspname FROM pg_namespace WHERE nspname !~ '^pg_.*'"
      ActiveRecord::Base.connection.query(sql).flatten
    end

  end
end
