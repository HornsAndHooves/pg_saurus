module PgPower
  class Engine < Rails::Engine

    initializer 'pg_power' do
      ActiveSupport.on_load(:active_record) do
        # load monkey patches
        require PgPower::Engine.root + 'lib/core_ext/active_record/connection_adapters/postgresql_adapter'

        ActiveRecord::ConnectionAdapters.module_eval do
          include PgPower::Schema::SchemaStatements
        end

        ActiveRecord::SchemaDumper.class_eval do
          include PgPower::SchemaDumper
        end

        if defined?(ActiveRecord::Migration::CommandRecorder)
          ActiveRecord::Migration::CommandRecorder.class_eval do
            include ::PgPower::Migration::CommandRecorder
          end
        end


        # pg_comment
        ActiveRecord::ConnectionAdapters.module_eval do
          include PgPower::ConnectionAdapters::SchemaStatements
          include PgPower::ConnectionAdapters::SchemaDefinitions
        end

        conf_name = ActiveRecord::Base.connection_pool.spec.config[:adapter]
        if conf_name == 'postgresql' then
          require 'pg_power/connection_adapters/postgresql_adapter'
        end

      end
    end 
  end
end
