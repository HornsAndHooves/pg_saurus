module PgSaurus
  # Base error for PgSaurus errors.
  class Error < StandardError; end

  # Raised when an unexpected index exists
  class IndexExistsError < Error; end

  # Raised if config.ensure_role_set = true, but migration have no role set.
  class RoleNotSetError < Error; end
end
