# Provides methods to extend ActiveRecord::Migration::CommandRecorder to
# support view feature.
module  PgSaurus::Migration::CommandRecorder::ViewMethods
  # Create a PostgreSQL view.
  #
  # @param args [Array] view_name and view_definition
  #
  # @return [view]
  def create_view(*args)
    record(:create_view, args)
  end

  # Drop a view in the DB.
  #
  # @param args [Array] first argument is view_name
  #
  # @return [void]
  def drop_view(*args)
    record(:drop_view, args)
  end

  # Invert the creation of a view in the DB.
  #
  # @param args [Array] first argument is supposed to be name of view
  #
  # @return [void]
  def invert_create_view(args)
    [:drop_view, [args.first]]
  end

end
