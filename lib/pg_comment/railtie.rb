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

        PgComment::Adapter.load!
      end
    end
  end
end