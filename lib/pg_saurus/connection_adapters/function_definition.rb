module PgSaurus::ConnectionAdapters
  # Struct definition for a DB function.
  class FunctionDefinition < Struct.new( :name,
                                         :returning,
                                         :definition,
                                         :function_type,
                                         :language,
                                         :oid )
  end
end
