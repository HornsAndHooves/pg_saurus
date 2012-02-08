# Provides methods to extend {ActiveRecord::Migration::CommandRecorder} to
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
  def invert_create_schema(args)
    [:drop_schema, [args.first]]
  end

  # :nodoc:
  def invert_drop_schema(args)
    [:create_schema, [args.first]]
  end
end
