module PgSaurus::ConnectionAdapters
  # Structure to store information about foreign keys related to from_table.
  class ForeignKeyDefinition < Struct.new(:from_table, :to_table, :options)
  end
end
