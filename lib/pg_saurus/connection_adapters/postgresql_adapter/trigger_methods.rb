# Provides methods to extend {ActiveRecord::ConnectionAdapters::PostgreSQLAdapter}
# to support db triggers.
module PgSaurus::ConnectionAdapters::PostgreSQLAdapter::TriggerMethods

  # :nodoc
  def supports_triggers?
    true
  end

  # See lib/pg_saurus/connection_adapters/trigger_methods.rb
  def create_trigger(table_name, proc_name, event, options = {})
    proc_name = "#{proc_name}"
    proc_name = "#{proc_name}()" unless proc_name.end_with?(')')

    for_each = options[:for_each] || 'ROW'
    constraint = options[:constraint]

    sql = if constraint
            "CREATE CONSTRAINT TRIGGER #{trigger_name(proc_name, options)}\n  #{event}\n"
          else
            "CREATE TRIGGER #{trigger_name(proc_name, options)}\n  #{event}\n"
          end

    sql << "  ON #{quote_table_or_view(table_name, options)}\n"
    if constraint
      sql << if options[:deferrable]
               "  DEFERRABLE INITIALLY #{!!options[:initially_deferred] ? 'DEFERRED' : 'IMMEDIATE'}\n"
             else
               "  NOT DEFERRABLE\n"
             end
    end
    sql << "  FOR EACH #{for_each}\n"
    if condition = options[:condition]
      sql << "  WHEN (#{condition})\n"
    end
    sql << "  EXECUTE PROCEDURE #{proc_name}"

    execute sql
  end

  # See lib/pg_saurus/connection_adapters/trigger_methods.rb
  def remove_trigger(table_name, proc_name, options = {})
    execute "DROP TRIGGER #{trigger_name(proc_name, options)} ON #{quote_table_or_view(table_name, options)}"
  end

  # Returns the listing of currently defined db triggers
  #
  # @return [Array<::PgSaurus::ConnectionAdapters::TriggerDefinition>]
  def triggers
    res = select_all <<-SQL
      SELECT n.nspname as schema,
             c.relname as table,
             t.tgname as trigger_name,
             t.tgenabled as enable_mode,
             t.tgdeferrable as is_deferrable,
             t.tginitdeferred as is_initially_deferrable,
             pg_catalog.pg_get_triggerdef(t.oid, true) as trigger_definition
      FROM pg_catalog.pg_trigger t
        INNER JOIN pg_catalog.pg_class c ON c.oid = t.tgrelid
        INNER JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
      WHERE c.relkind IN ('r', 'v')
        AND NOT t.tgisinternal
      ORDER BY 1, 2, 3;
    SQL

    res.inject([]) do |buffer, row|
      schema                = row['schema']
      table                 = row['table']
      trigger_name          = row['trigger_name']
      is_deferrable         = row['is_deferrable']
      is_initially_deferred = row['is_initially_deferred']

      trigger_definition = row['trigger_definition']

      is_constraint = is_constraint?(trigger_definition)
      proc_name     = parse_proc_name(trigger_definition)
      event         = parse_event(trigger_definition, trigger_name)
      condition     = parse_condition(trigger_definition)

      for_every = !!(trigger_definition =~ /FOR[\s]EACH[\s]ROW/) ? :row : :statement

      if proc_name && event
        buffer << ::PgSaurus::ConnectionAdapters::TriggerDefinition.new(
          trigger_name,
          proc_name,
          is_constraint,
          event,
          for_every,
          is_deferrable,
          is_initially_deferred,
          condition,
          table,
          schema
        )
      end
      buffer
    end
  end

  def parse_condition(trigger_definition)
    trigger_definition[/WHEN[\s](.*?)[\s]EXECUTE[\s]PROCEDURE/m, 1]
  end
  private :parse_condition

  def parse_event(trigger_definition, trigger_name)
    trigger_definition[/^CREATE[\sA-Z]+TRIGGER[\s]#{Regexp.escape(trigger_name)}[\s](.*?)[\s]ON[\s]/m, 1]
  end
  private :parse_event

  def parse_proc_name(trigger_definition)
    trigger_definition[/EXECUTE[\s]PROCEDURE[\s](.*?)$/m,1]
  end
  private :parse_proc_name

  def is_constraint?(trigger_definition)
    !!(trigger_definition =~ /^CREATE CONSTRAINT TRIGGER/)
  end
  private :is_constraint?

  def quote_table_or_view(name, options)
    schema = options[:schema]
    if schema
      "\"#{schema}\".\"#{name}\""
    else
      "\"#{name}\""
    end
  end
  private :quote_table_or_view

  def trigger_name(proc_name, options)
    if name = options[:name]
      name
    else
      "trigger_#{proc_name.gsub('(', '').gsub(')', '')}"
    end
  end
  private :trigger_name

end
