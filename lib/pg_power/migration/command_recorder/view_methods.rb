# Provides methods to extend {ActiveRecord::Migration::CommandRecorder} to
# support view feature.
module  PgPower::Migration::CommandRecorder::ViewMethods
  # :nodoc:
  def create_view(*args)
    record(:create_view, args)
  end

  # :nodoc:
  def drop_view(*args)
    record(:drop_view, args)
  end

  # :nodoc:
  def invert_create_view(args)
    [:drop_view, [args.first]]
  end

  # :nodoc:
  def invert_drop_view(args)
    raise ActiveRecord::IrreversibleMigration, "drop_view is only reversible if given a view_definition." if args.size < 2
    [:create_view, args]
  end
end
