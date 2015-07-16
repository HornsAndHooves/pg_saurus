# Extends ActiveRecord::ConnectionAdapters::AbstractAdapter
# with methods for multi-schema support.
module PgSaurus::ConnectionAdapters::AbstractAdapter::SchemaMethods

  # Provide :schema option to +create_table+ method.
  def create_table_with_schema_option(table_name, options = {}, &block)
    options     = options.dup
    schema_name = options.delete(:schema)
    table_name  = "#{schema_name}.#{table_name}" if schema_name
    create_table_without_schema_option(table_name, options, &block)
  end

  # Provide :schema option to +drop_table+ method.
  def drop_table_with_schema_option(table_name, options = {})
    options     = options.dup
    schema_name = options.delete(:schema)
    table_name  = "#{schema_name}.#{table_name}" if schema_name
    drop_table_without_schema_option(table_name, options)
  end
end
