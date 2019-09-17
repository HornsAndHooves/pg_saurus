module PgSaurus
  # :nodoc:
  class Engine < Rails::Engine

    initializer 'pg_saurus' do
      ActiveSupport.on_load(:active_record) do
        # load monkey patches
        ['schema_dumper',
         'errors',
         'connection_adapters/postgresql_adapter',
         'connection_adapters/postgresql/schema_statements'].each do |path|
          require ::PgSaurus::Engine.root + 'lib/core_ext/active_record/' + path
        end

        ActiveRecord::SchemaDumper.class_eval do
          prepend ::PgSaurus::SchemaDumper::SchemaMethods
          prepend ::PgSaurus::SchemaDumper::ExtensionMethods
          prepend ::PgSaurus::SchemaDumper::ViewMethods
          prepend ::PgSaurus::SchemaDumper::FunctionMethods
          prepend ::PgSaurus::SchemaDumper::CommentMethods
          prepend ::PgSaurus::SchemaDumper::TriggerMethods
          prepend ::PgSaurus::SchemaDumper::ForeignKeyMethods

          include ::PgSaurus::SchemaDumper
        end

        ActiveRecord::Migration.class_eval do
          prepend ::PgSaurus::Migration::SetRoleMethod::Extension
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
          prepend PgSaurus::CreateIndexConcurrently::Migrator
        end
        ActiveRecord::MigrationProxy.class_eval do
          include ::PgSaurus::CreateIndexConcurrently::MigrationProxy
        end

        ActiveRecord::ConnectionAdapters::Table.module_eval do
          include ::PgSaurus::ConnectionAdapters::Table
        end

        ActiveRecord::ConnectionAdapters::AbstractAdapter.module_eval do
          prepend ::PgSaurus::ConnectionAdapters::AbstractAdapter::SchemaMethods
          include ::PgSaurus::ConnectionAdapters::AbstractAdapter
        end

        if defined?(ActiveRecord::ConnectionAdapters::JdbcAdapter)
          sql_adapter_class = ActiveRecord::ConnectionAdapters::JdbcAdapter
        else
          sql_adapter_class = ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
        end

        sql_adapter_class.class_eval do
          prepend ::PgSaurus::ConnectionAdapters::PostgreSQLAdapter::SchemaMethods
          prepend ::PgSaurus::ConnectionAdapters::PostgreSQLAdapter::ForeignKeyMethods

          include ::PgSaurus::ConnectionAdapters::PostgreSQLAdapter
        end

      end
    end

  end
end
