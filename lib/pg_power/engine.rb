module PgPower
  # :nodoc
  class Engine < Rails::Engine

    initializer 'pg_power' do
      ActiveSupport.on_load(:active_record) do
        # load monkey patches
        ['schema_dumper',
         'connection_adapters/postgresql_adapter',
         'connection_adapters/abstract/schema_statements'].each do |path|
          require PgPower::Engine.root + 'lib/core_ext/active_record/' + path
        end

        ActiveRecord::SchemaDumper.class_eval do
          include PgPower::SchemaDumper
        end

        if defined?(ActiveRecord::Migration::CommandRecorder)
          ActiveRecord::Migration::CommandRecorder.class_eval do
            include ::PgPower::Migration::CommandRecorder
          end
        end

        ActiveRecord::ConnectionAdapters::Table.module_eval do
          include PgPower::ConnectionAdapters::Table
        end

        ActiveRecord::ConnectionAdapters::AbstractAdapter.module_eval do
          include PgPower::ConnectionAdapters::AbstractAdapter
        end

        if defined?(ActiveRecord::ConnectionAdapters::JdbcAdapter)
          sql_adapter_class = ActiveRecord::ConnectionAdapters::JdbcAdapter
        else
          sql_adapter_class = ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
        end

        sql_adapter_class.class_eval do
          include PgPower::ConnectionAdapters::PostgreSQLAdapter
        end

      end
    end

  end
end
