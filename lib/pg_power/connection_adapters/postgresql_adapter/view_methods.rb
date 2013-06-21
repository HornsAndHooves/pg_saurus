# Provides methods to extend {ActiveRecord::ConnectionAdapters::PostgreSQLAdapter}
# to support views feature.
module PgPower::ConnectionAdapters::PostgreSQLAdapter::ViewMethods
  # Creates new view in DB.
  # @param [String] view_name
  # @param [String] sql
  def create_view(view_name, sql)
    ::PgPower::Tools.create_view(view_name, sql)
  end

  # Drops schema in DB.
  # @param [String] schema_name
  def drop_view(view_name)
    ::PgPower::Tools.drop_view(view_name)
  end

end
