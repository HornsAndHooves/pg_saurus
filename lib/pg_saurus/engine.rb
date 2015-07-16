module PgSaurus
  # :nodoc:
  class Engine < Rails::Engine

    initializer 'pg_saurus' do
      ActiveSupport.on_load(:active_record) do
        # load monkey patches
        ['schema_dumper',
         'errors',
         'connection_adapters/postgresql_adapter',
         'connection_adapters/abstract/schema_statements'].each do |path|
          require ::PgSaurus::Engine.root + 'lib/core_ext/active_record/' + path
        end

        ActiveRecord::SchemaDumper.class_eval { include ::PgSaurus::SchemaDumper }

        ActiveRecord::Migration.class_eval do
          include ::PgSaurus::Migration::SetRoleMethod
        end

        if defined?(ActiveRecord::Migration::CommandRecorder)
          ActiveRecord::Migration::CommandRecorder.class_eval do
            include ::PgSaurus::Migration::CommandRecorder
          end
        end

        # Follow three include statements add support for concurrently
        #   index creation in migrations.
        ActiveRecord::Migration.class_eval do
          include ::PgSaurus::CreateIndexConcurrently::Migration
        end
        ActiveRecord::Migrator.class_eval do
          include ::PgSaurus::CreateIndexConcurrently::Migrator
        end
        ActiveRecord::MigrationProxy.class_eval do
          include ::PgSaurus::CreateIndexConcurrently::MigrationProxy
        end

        ActiveRecord::ConnectionAdapters::Table.module_eval do
          include ::PgSaurus::ConnectionAdapters::Table
        end

        ActiveRecord::ConnectionAdapters::AbstractAdapter.module_eval do
          include ::PgSaurus::ConnectionAdapters::AbstractAdapter
        end

        if defined?(ActiveRecord::ConnectionAdapters::JdbcAdapter)
          sql_adapter_class = ActiveRecord::ConnectionAdapters::JdbcAdapter
        else
          sql_adapter_class = ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
        end

        sql_adapter_class.class_eval do
          include ::PgSaurus::ConnectionAdapters::PostgreSQLAdapter
        end

      end
    end

  end
end
