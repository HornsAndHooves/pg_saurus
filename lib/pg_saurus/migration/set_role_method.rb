module PgSaurus
  # Wrap original `exec_migration` to run migration with set postgresql role.
  # If config.ensure_role_set=true but no role is set for the migration, then an
  # exception is raised.
  module Migration::SetRoleMethod
    extend ActiveSupport::Concern

    included do
      class << self
        attr_reader :role

        # Set role
        #
        # @param role [String]
        def set_role(role)
          if const_defined?("SeedMigrator") && self.ancestors.include?(SeedMigrator)
            msg = <<~MSG
              Use keep_default_role instead of set_role for data change migration #{self}

              Example:

                class PopulateExample < ActiveRecord::Migration
                  include #{self.ancestors[1]}

                  keep_default_role

                  def up
                    apply_update "populate_example_data_update"
                  end

                  def down
                    revert_update "populate_example_data_update"
                  end
                end
            MSG

            raise PgSaurus::UseKeepDefaultRoleError, msg
          end

          @role = role
        end

        # Prevents raising exception when ensure_role_set=true and no role is set.
        def keep_default_role
          if const_defined?("SeedMigrator") && !self.ancestors.include?(SeedMigrator)
            msg = <<~MSG
              Use set_role instead of keep_default_role for structure migration #{self}

              Example:

                class CreateExamples < ActiveRecord::Migration
                  set_role "superhero"

                  def up
                    ...
                  end

                  def down
                    ...
                  end
                end
            MSG

            raise PgSaurus::UseSetRoleError, msg
          end

          @keep_default_role = true
        end

        # Was +keep_default_role+ called for the migration?
        #
        # @return [Boolean]
        def keep_default_role?
          @keep_default_role
        end
      end
    end

    # Get role
    def role
      self.class.role
    end

    # :nodoc:
    def keep_default_role?
      self.class.keep_default_role?
    end

    # Module to be prepended into ActiveRecord::Migration which allows
    # enhancing the exec_migration method.
    module Extension
      # Wrap original `exec_migration` to run migration with set role.
      #
      # @param conn [ActiveRecord::ConnectionAdapters::PostgreSQLAdapter]
      # @param direction [Symbol] :up or :down
      #
      # @return [void]
      def exec_migration(conn, direction)
        if role
          begin
            conn.execute "SET ROLE #{role}"
            super(conn, direction)
          ensure
            conn.execute "RESET ROLE"
          end
        elsif PgSaurus.config.ensure_role_set && !keep_default_role?
          msg =
            "Role for migration #{self.class} is not set\n\n" \
            "You've configured PgSaurus with ensure_role_set=true. \n" \
            "That means that every migration must explicitly set role with set_role method.\n\n" \
            "Example:\n" \
            "  class CreateNewTable < ActiveRecord::Migration\n" \
            "    set_role \"superhero\"\n" \
            "  end\n\n" \
            "If you want to set ensure_role_set=false, take a look at config/initializers/pg_saurus.rb\n\n"
          raise PgSaurus::RoleNotSetError, msg
        else
          super(conn, direction)
        end
      end
    end

  end
end
