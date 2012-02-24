# Extends {ActiveRecord::ConnectionAdapters::AbstractAdapter}
module PgPower::ConnectionAdapters::AbstractAdapter::IndexMethods
  def supports_partial_index?
    false
  end
end