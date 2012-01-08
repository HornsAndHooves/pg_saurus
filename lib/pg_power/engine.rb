module PgPower
  class Engine < Rails::Engine

    initializer 'pg_power' do
      ActiveSupport.on_load(:active_record) do
        require 'pg_power/active_record/schema_dumper'

        ActiveRecord::ConnectionAdapters.module_eval do
          include PgPower::Schema::SchemaStatements
        end

        if defined?(ActiveRecord::Migration::CommandRecorder)
          ActiveRecord::Migration::CommandRecorder.class_eval do
            include ::PgPower::Migration::CommandRecorder
          end
        end

      end
    end 
  end
end
