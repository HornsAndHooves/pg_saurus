# frozen_string_literal: true

module ActiveRecord
  class Migration
    module Compatibility
      # PgSaurus has been properly creating functional index names since Rails 4, so we don't want the old logic
      class V7_0
        module TableDefinition
          # Override https://github.com/rails/rails/blob/v7.2.2.2/activerecord/lib/active_record/migration/compatibility.rb#L80
          def index(...)
            super
          end
        end

        # Override https://github.com/rails/rails/blob/v7.2.2.2/activerecord/lib/active_record/migration/compatibility.rb#L102
        def add_index(...)
          super
        end
      end
    end
  end
end
