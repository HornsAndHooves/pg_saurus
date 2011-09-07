module PgComment
  class Railtie < Rails::Railtie
    initializer 'pg_comment.load_adapter' do
      ActiveSupport.on_load :active_record do
        ActiveRecord::ConnectionAdapters.module_eval do
          include PgComment::ConnectionAdapters::SchemaStatements
          include PgComment::ConnectionAdapters::SchemaDefinitions
        end

        ActiveRecord::SchemaDumper.class_eval do
          include PgComment::SchemaDumper
        end

        if defined?(ActiveRecord::Migration::CommandRecorder)
          ActiveRecord::Migration::CommandRecorder.class_eval do
            include PgComment::Migration::CommandRecorder
          end
        end

        conf_name = ActiveRecord::Base.connection_pool.spec.config[:adapter]
        if conf_name == 'postgresql' then
          require 'pg_comment/connection_adapters/postgresql_adapter'
        end
      end
    end
  end
end