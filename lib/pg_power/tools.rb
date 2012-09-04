module PgPower
  # Provides utility methods to work with PostgreSQL databases.
  # Usage:
  #   PgPower::Tools.create_schema "services"  # => create new PG schema "services"
  #   PgPower::Tools.create_schema "nets"
  #   PgPower::Tools.drop_schema "services"    # => remove the schema
  #   PgPower::Tools.schemas                   # => ["public", "information_schema", "nets"]
  #   PgPower::Tools.move_table_to_schema :computers, :nets
  module Tools
    extend self

    # Creates PostgreSQL schema
    def create_schema(schema_name)
      sql = %{CREATE SCHEMA "#{schema_name}"}
      connection.execute sql
    end

    # Drops PostgreSQL schema
    def drop_schema(schema_name)
      sql = %{DROP SCHEMA "#{schema_name}"}
      connection.execute sql
    end

    # Returns an array of existing schemas.
    def schemas
      sql = "SELECT nspname FROM pg_namespace WHERE nspname !~ '^pg_.*' order by nspname"
      connection.query(sql).flatten
    end

    # Move table to another schema without loosing data, indexes or constraints.
    # @param [String] table table name (schema prefix is allowed)
    # @param [String] new_schema schema where table should be moved to
    def move_table_to_schema(table, new_schema)
      schema, table = to_schema_and_table(table)
      sql = %{ALTER TABLE "#{schema}"."#{table}" SET SCHEMA "#{new_schema}"}
      connection.execute sql
    end



    # Return database connections
    def connection
      ActiveRecord::Base.connection
    end
    private :connection

    # Extract schema name and table name from qualified table name
    # @param [String, Symbol] table_name table name
    # @return [Array[String, String]] schema and table
    def to_schema_and_table(table_name)
      table, schema = table_name.to_s.split(".", 2).reverse
      schema ||= "public"
      [schema, table]
    end
  end
end
