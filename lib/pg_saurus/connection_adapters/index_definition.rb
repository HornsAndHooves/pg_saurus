module PgSaurus::ConnectionAdapters
  # Structure to store index parameters
  # Overrides ActiveRecord::ConnectionAdapters::IndexDefinition
  # with the additional :where parameter.
  class IndexDefinition < Struct.new( :table, :name, :unique, :columns,
                                      :lengths, :where, :access_method )
  end
end
