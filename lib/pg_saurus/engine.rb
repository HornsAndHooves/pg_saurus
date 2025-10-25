module PgSaurus
  # :nodoc:
  class Engine < Rails::Engine

    # Postgres server version.
    #
    # @return [Array<Integer>]
    def self.pg_server_version
      @pg_server_version ||=
        ::ActiveRecord::Base.connection.
          select_value('SHOW SERVER_VERSION').
          split('.')[0..1].map(&:to_i)
    end

    initializer "pg_saurus" do
      ActiveSupport.on_load(:active_record) do
        # load monkey patches
        %w[
          errors
          connection_adapters/postgresql/schema_statements
          migration/compatibility
        ].each do |path|
          require ::PgSaurus::Engine.root + "lib/core_ext/active_record/" + path
        end

        ActiveRecord::ConnectionAdapters::PostgreSQL::SchemaDumper.class_eval do
          prepend ::PgSaurus::SchemaDumper::ViewMethods  # create_view
          prepend ::PgSaurus::SchemaDumper::FunctionMethods
          prepend ::PgSaurus::SchemaDumper::TriggerMethods
          prepend ::PgSaurus::SchemaDumper::ForeignKeyMethods
          prepend ::PgSaurus::SchemaDumper::SchemaMethods

          include ::PgSaurus::SchemaDumper
        end

        ActiveRecord::Migration.class_eval do
          include ::PgSaurus::Migration::SetRoleMethod
        end

        if defined?(ActiveRecord::Migration::CommandRecorder)
          ActiveRecord::Migration::CommandRecorder.class_eval do
            include ::PgSaurus::Migration::CommandRecorder
          end
        end

        ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
          prepend ::PgSaurus::ConnectionAdapters::PostgreSQLAdapter::SchemaMethods
          prepend ::PgSaurus::ConnectionAdapters::PostgreSQLAdapter::ForeignKeyMethods

          include ::PgSaurus::ConnectionAdapters::PostgreSQLAdapter
        end

      end
    end

  end
end
