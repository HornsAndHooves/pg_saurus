# Provides methods to extend {ActiveRecord::Migration::CommandRecorder} to
# support view feature.
module  PgPower::Migration::CommandRecorder::ViewMethods
  
  # Creates PostgreSQL view
  # @param [String, Symbol] view_name
  # @param [String] view_definition
  def create_view(*args)
    record(:create_view, args)
  end

  # Drops view in DB.
  # @param [String, Symbol] view_name
  def drop_view(*args)
    record(:drop_view, args)
  end

  # Inverts creation of a view in DB.
  # @param [String, Symbol] view_name
  def invert_create_view(args)
    [:drop_view, [args.first]]
  end
  
end
