# Extends ActiveRecord::ConnectionAdapters::AbstractAdapter.
module PgSaurus::ConnectionAdapters::AbstractAdapter::IndexMethods
  def supports_partial_index?
    false
  end
end
