# Provides methods to extend {ActiveRecord::ConnectionAdapters::PostgreSQLAdapter}
# to support views feature.
module PgPower::ConnectionAdapters::PostgreSQLAdapter::ViewMethods
  # Creates new view in DB.
  # @param [String] view_name
  # @param [String] view_definition
  def create_view(view_name, view_definition)
    ::PgPower::Tools.create_view(view_name, view_definition)
  end

  # Drops schema in DB.
  # @param [String] schema_name
  def drop_view(view_name)
    ::PgPower::Tools.drop_view(view_name)
  end

end
