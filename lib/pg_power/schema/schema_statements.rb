module PgPower
  module Schema

    module SchemaStatements
      def self.included(base)
        base::AbstractAdapter.class_eval do
          include ::PgPower::Schema::AbstractAdapter
        end
      end
    end

    module AbstractAdapter
      def create_schema(schema_name)
        ::PgPower::Tools.create_schema(schema_name)
      end

      def drop_schema(schema_name)
        ::PgPower::Tools.drop_schema(schema_name)
      end
    end

  end
end
