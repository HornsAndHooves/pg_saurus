module PgPower::Generators::MigrationGenerator
  def self.included(base) #:nodoc:
    base.source_root File.expand_path(File.join('lib', 'pg_power', 'generators', 'templates'), ::PgPower::Engine.root)
  end
end
