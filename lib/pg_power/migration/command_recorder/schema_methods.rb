# Provides methods to extend ActiveRecord::Migration::CommandRecorder to
# support multi schemas feature.
module  PgPower::Migration::CommandRecorder::SchemaMethods
  # :nodoc:
  def create_schema(*args)
    record(:create_schema, args)
  end

  # :nodoc:
  def drop_schema(*args)
    record(:drop_schema, args)
  end

  # :nodoc:
  def move_table_to_schema(*args)
    record(:move_table_to_schema, args)
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

    new_schema, table = ::PgPower::Tools.to_schema_and_table(table_name)

    invert_args = ["#{current_schema}.#{table}", new_schema]
    [:move_table_to_schema, invert_args]
  end
end
