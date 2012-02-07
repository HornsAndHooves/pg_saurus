# Extends ActiveRecord::SchemaDumper class to dump schemas other than "public"
# and tables from those schemas.
module PgPower::SchemaDumper::SchemaMethods
  # * Dumps schemas.
  # * Dumps tables from public schema using native #tables method.
  # * Dumps tables from schemas other than public.
  def tables_with_schemas(stream)
    schemas(stream)
    tables_without_schemas(stream)
    non_public_schema_tables(stream)
  end

  # Generates code to create schemas.
  def schemas(stream)
    # Don't create "public" schema since it exists by default.
    schema_names = PgPower::Tools.schemas - ["public", "information_schema"]
    schema_names.each do |schema|
      schema(schema, stream)
    end
    stream << "\n"
  end
  private :schemas

  # Generates code to create schema.
  def schema(schema_name, stream)
    stream << "  create_schema \"#{schema_name}\"\n"
  end
  private :schema

  # Dumps tables from schemas other than public
  def non_public_schema_tables(stream)
    get_non_public_schema_table_names.each do |name|
      table(name, stream)
    end
  end
  private :non_public_schema_tables

  # Returns the list of non public schema tables
  # Usage:
  #   get_non_public_schema_table_names # => ['demography.countries', 'demography.cities', 'politics.members']
  def get_non_public_schema_table_names
    result = @connection.query(<<-SQL, 'SCHEMA')
      SELECT schemaname || '.' || tablename
      FROM pg_tables
      WHERE schemaname NOT IN ('pg_catalog', 'information_schema', 'public')
    SQL
    result.flatten
  end
  private :get_non_public_schema_table_names
end