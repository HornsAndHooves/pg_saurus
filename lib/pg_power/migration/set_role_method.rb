module PgPower
  # Wrap original `exec_migration` to run migration with set postgresql rol.
  # If config.ensure_role_set=true but not role set for migration that
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
          @role = role
        end
      end

      alias_method_chain :exec_migration, :role
    end

    # Get role
    def role
      self.class.role
    end

    # Wrap original `exec_migration` to run migration with set role.
    #
    # @param conn [ActiveRecord::ConnectionAdapters::PostgreSQLAdapter]
    # @param direction [Symbole] :up or :down
    #
    # @return [void]
    def exec_migration_with_role(conn, direction)
      if role
        begin
          conn.execute "SET ROLE #{role}"
          exec_migration_without_role(conn, direction)
        ensure
          conn.execute "RESET ROLE"
        end
      elsif PgPower.config.ensure_role_set
        msg =
          "Role for migration #{self.class} is not set\n\n" \
          "You've configured PgPower with ensure_role_set=true. \n" \
          "That means that every migration must explicitly set role with set_role method.\n\n" \
          "Example:\n" \
          "  class CreateNewTable < ActiveRecord::Migration\n" \
          "    set_role \"superhero\"\n" \
          "  end\n\n" \
          "If you want to set ensure_role_set=false, take a look at config/initializers/pg_power.rb\n\n"
        raise PgPower::RoleNotSetError, msg
      else
        exec_migration_without_role(conn, direction)
      end
    end

  end
end
