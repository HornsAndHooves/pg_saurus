module PgPower
  module Migration
    module CommandRecorder

      def create_schema(*args)
        record(:create_schema, args)
      end

      def drop_schema(*args)
        record(:drop_schema, args)
      end

      def invert_create_schema(args)
        [:drop_schema, [args.first]]
      end

      def invert_drop_schema(args)
        [:create_schema, [args.first]]
      end

    end
  end
end
