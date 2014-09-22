module PgSaurus
  # Configuration for PgSaurus behaviour.
  class Config
    # When true, raise exception if migration is executed without a role.
    attr_accessor :ensure_role_set

    # Instantiate and set default config settings.
    def initialize
      @ensure_role_set = false
    end
  end
end
