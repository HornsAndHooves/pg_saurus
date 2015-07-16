# Support for dumping database triggers.
module PgSaurus::SchemaDumper::TriggerMethods

  # :nodoc
  def tables_with_triggers(stream)
    tables_without_triggers(stream)

    dump_triggers(stream)
    stream.puts

    stream
  end

  # Write out a command to create each detected trigger.
  def dump_triggers(stream)
    @connection.triggers.each do |trigger|
      statement = "  create_trigger '#{trigger.table}', '#{trigger.proc_name}', '#{trigger.event}', " \
        "name: '#{trigger.name}', " \
        "constraint: #{trigger.constraint ? :true : :false}, " \
        "for_each: :#{trigger.for_each}, " \
        "deferrable: #{trigger.deferrable ? :true : :false}, " \
        "initially_deferred: #{trigger.initially_deferred ? :true : :false}, " \
        "schema: '#{trigger.schema}'"

      if trigger.condition
        statement << %Q{, condition: '#{trigger.condition.gsub("'", %q(\\\'))}'}
      end

      stream.puts "#{statement}\n"
    end
  end

end
