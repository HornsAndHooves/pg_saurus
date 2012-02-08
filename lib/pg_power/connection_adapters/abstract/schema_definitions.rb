module PgPower
  module ConnectionAdapters
    module SchemaDefinitions

      def self.included(base)
        base::Table.class_eval do
          include PgPower::ConnectionAdapters::Table
        end
      end

    end
  end
end
