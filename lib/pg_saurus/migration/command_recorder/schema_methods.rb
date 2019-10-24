# Provides methods to extend ActiveRecord::Migration::CommandRecorder to
# support multi schemas feature.
module  PgSaurus::Migration::CommandRecorder::SchemaMethods

  [
    :create_schema,
    :drop_schema,
    :move_table_to_schema,
    :create_schema_if_not_exists,
    :drop_schema_if_exists
  ].each do |method_name|
    define_method(method_name) do |*args|
      record method_name, args
    end
  end

  # :nodoc:
  def invert_create_schema(args)
    [:drop_schema, [args.first]]
  end

  # :nodoc:
  def invert_drop_schema(args)
    [:create_schema, [args.first]]
  end

  # :nodoc:
  def invert_move_table_to_schema(args)
    table_name     = args.first
    current_schema = args.second

    new_schema, table = ::PgSaurus::Tools.to_schema_and_table(table_name)

    invert_args = ["#{current_schema}.#{table}", new_schema]
    [:move_table_to_schema, invert_args]
  end

  # :nodoc:
  def invert_create_schema_if_not_exists(*args)
    [:drop_schema_if_exists, args]
  end

  # :nodoc:
  def invert_drop_schema_if_exists(*args)
    [:create_schema_if_not_exists, args]
  end
end
