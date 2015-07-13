module PgSaurus::ConnectionAdapters

  # Struct definition for a db function
  class FunctionDefinition < Struct.new( :name,
                                         :returning,
                                         :definition,
                                         :function_type,
                                         :language,
                                         :oid )

  end
end
