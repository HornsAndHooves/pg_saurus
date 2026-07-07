# Extends ActiveRecord::SchemaDumper class to dump schemas other than "public"
# and tables from those schemas.
module PgSaurus::SchemaDumper::SchemaMethods

  # Overrides https://github.com/rails/rails/blob/v7.2.2.2/activerecord/lib/active_record/schema_dumper.rb#L95
  def header(stream)
    super
    dump_all_schemas(stream)
  end

  # Remove per-schema dumping logic from https://github.com/rails/rails/pull/50020
  # https://github.com/rails/rails/blob/v8.1.3/activerecord/lib/active_record/connection_adapters/postgresql/schema_dumper.rb#L142
  def within_each_schema
    yield
  end

  # Overrides https://github.com/rails/rails/blob/v7.2.2.2/activerecord/lib/active_record/connection_adapters/postgresql/schema_dumper.rb#L31
  #
  # We are already dumping the schemas through #header
  def schemas(...)
  end

  # Generates code to create schemas.
  private def dump_all_schemas(stream)
    # Don't create "public" schema since it exists by default.
    schema_names = PgSaurus::Tools.schemas - %w[public information_schema]
    schema_names.each do |schema_name|
      stream.puts %(  create_schema_if_not_exists "#{schema_name}")
    end
    stream.puts
  end
end
