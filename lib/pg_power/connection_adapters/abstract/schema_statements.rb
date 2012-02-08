module PgPower
  module ConnectionAdapters
    module SchemaStatements
      def self.included(base)
        base::AbstractAdapter.class_eval do
          include PgPower::ConnectionAdapters::AbstractAdapter
        end
      end
    end

  end
end
