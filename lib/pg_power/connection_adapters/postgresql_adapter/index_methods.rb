# Extends {ActiveRecord::ConnectionAdapters::PostgresAdapter}
module PgPower::ConnectionAdapters::PostgreSQLAdapter::IndexMethods
  def supports_partial_index?
    true
  end
end