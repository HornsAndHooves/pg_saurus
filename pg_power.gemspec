$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "pg_power/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "pg_power"
  s.version     = PgPower::VERSION
  s.authors     = ["Potapov Sergey"]
  s.email       = ["blake131313@gmail.com"]
  s.summary     = "ActiveRecord extensions for PostgreSQL."
  s.description = "ActiveRecord extensions for PostgreSQL. Provides useful tools and ability to create/drop schemas in migrations."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.markdown"]

  s.add_dependency "rails", "~> 3.1.3"
  s.add_development_dependency "pg"
end
