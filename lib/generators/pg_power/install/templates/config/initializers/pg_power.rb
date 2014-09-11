# Configure PgPower behaviour.
#
PgPower.configure do |config|
  # Set to true if you want to enforce migrations to set role.
  config.ensure_role_set = false
end
