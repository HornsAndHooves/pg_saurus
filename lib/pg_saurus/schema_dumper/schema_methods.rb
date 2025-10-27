# Extends ActiveRecord::SchemaDumper class to dump schemas other than "public"
# and tables from those schemas.
module PgSaurus::SchemaDumper::SchemaMethods

  # Overrides https://github.com/rails/rails/blob/v7.2.2.2/activerecord/lib/active_record/schema_dumper.rb#L95
  def header(stream)
    super
    dump_schemas(stream)
  end

  # Overrides https://github.com/rails/rails/blob/v7.2.2.2/activerecord/lib/active_record/connection_adapters/postgresql/schema_dumper.rb#L31
  #
  # We are already dumping the schemas through #header
  def schemas(...)
  end

  # Generates code to create schemas.
  def dump_schemas(stream)
    # Don't create "public" schema since it exists by default.
    schema_names = PgSaurus::Tools.schemas - ["public", "information_schema"]
    schema_names.each do |schema_name|
      dump_schema(schema_name, stream)
    end
    stream.puts
  end
  private :dump_schemas

  # Generates code to create schema.
  def dump_schema(schema_name, stream)
    stream.puts %(  create_schema_if_not_exists "#{schema_name}")
  end
  private :dump_schema
end
