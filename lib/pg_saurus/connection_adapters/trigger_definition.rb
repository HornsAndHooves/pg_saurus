module PgSaurus::ConnectionAdapters

  # Struct definition for a DB trigger.
  class TriggerDefinition < Struct.new( :name,
                                        :proc_name,
                                        :constraint,
                                        :event,
                                        :for_each,
                                        :deferrable,
                                        :initially_deferred,
                                        :condition,
                                        :table,
                                        :schema )

  end
end
