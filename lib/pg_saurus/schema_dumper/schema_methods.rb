# Extends ActiveRecord::SchemaDumper class to dump schemas other than "public"
# and tables from those schemas.
module PgSaurus::SchemaDumper::SchemaMethods
  # Generates code to create schemas.
  private def schemas(stream)
    schema_names = @connection.schema_names - ["public"]

    if schema_names.any?
      schema_names.sort.each do |name|
        stream.puts "  create_schema #{name.inspect}, if_not_exists: true"
      end
      stream.puts
    end
  end
end
