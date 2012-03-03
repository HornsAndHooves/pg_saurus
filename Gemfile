source "http://rubygems.org"

# Declare your gem's dependencies in pg_power.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

gem 'pg'
#gem 'activerecord-jdbcpostgresql-adapter'

# rake spec fails if this is in the :development group:
gem 'rspec-rails'

group :development do
  # code metrics:
  gem 'rcov'
  gem 'yard'
  gem 'metrical', :require => false

  gem "ruby-debug"  , :platforms => :ruby_18
  gem "ruby-debug19", :platforms => :ruby_19
end
