# Extends ActiveRecord::SchemaDumper class to dump schemas other than "public"
# and tables from those schemas.
module PgSaurus::SchemaDumper::SchemaMethods
  # Dump create schema statements
  def header_with_schemas(stream)
    header_without_schemas(stream)
    schemas(stream)
    stream
  end

  # Generates code to create schemas.
  def schemas(stream)
    # Don't create "public" schema since it exists by default.
    schema_names = PgSaurus::Tools.schemas - ["public", "information_schema"]
    schema_names.each do |schema_name|
      schema(schema_name, stream)
    end
    stream << "\n"
  end
  private :schemas

  # Generates code to create schema.
  def schema(schema_name, stream)
    stream << "  create_schema \"#{schema_name}\"\n"
  end
  private :schema
end
