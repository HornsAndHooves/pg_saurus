module PgComment
  class Adapter
    def self.load!
      conf_name = ActiveRecord::Base.connection_pool.spec.config[:adapter]
      if conf_name == 'postgresql' then
        require 'pg_comment/connection_adapters/postgresql_adapter'
      end
    end

  end
end