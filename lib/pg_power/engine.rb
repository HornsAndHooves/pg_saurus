module PgPower
  class Engine < Rails::Engine

    initializer 'pg_power' do
      ActiveSupport.on_load(:active_record) do

        ActiveRecord::SchemaDumper.class_eval do
          include PgPower::SchemaDumper
        end

        if defined?(ActiveRecord::Migration::CommandRecorder)
          ActiveRecord::Migration::CommandRecorder.class_eval do
            include ::PgPower::Migration::CommandRecorder
          end
        end

        ActiveRecord::ConnectionAdapters.module_eval do
          include PgPower::ConnectionAdapters::SchemaStatements
          include PgPower::ConnectionAdapters::SchemaDefinitions
        end

        conf_name = ActiveRecord::Base.connection_pool.spec.config[:adapter]
        PgPower::Engine.patch_pg_adapter! if conf_name == 'postgresql'
      end
    end 


    def self.patch_pg_adapter!
      # load monkey patches
      require PgPower::Engine.root + 'lib/core_ext/active_record/connection_adapters/postgresql_adapter'
      require 'pg_power/connection_adapters/postgresql_adapter'

      [:PostgreSQLAdapter, :JdbcAdapter].each do |adapter|
        begin
          ActiveRecord::ConnectionAdapters.const_get(adapter).class_eval do
            include PgPower::ConnectionAdapters::PostgreSQLAdapter
          end
        rescue NameError
        end
      end
    end

  end
end
