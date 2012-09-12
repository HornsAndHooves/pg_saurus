source "http://rubygems.org"

# To test against different rails versions with TravisCI
rails_version = ENV['RAILS_VERSION'] || '~> 3.1'

# NOTE: This is a Gemfile for a gem.
# Using 'platforms' is contraindicated because they won't make it into
# the gemspec correctly.
java_platform = (RUBY_PLATFORM =~ /java/)
version19 = (RUBY_VERSION =~ /^1\.9/)
version18 = (RUBY_VERSION =~ /^1\.8/)

gem 'pg'
#gem 'activerecord-jdbcpostgresql-adapter'

# rake spec fails if this is in the :development group:
gem 'rspec-rails'
gem 'rails', rails_version

group :development do
  # code metrics:
  gem 'rcov'
  gem 'yard'
  gem 'metrical', :require => false
  gem 'jeweler', :require => false


  unless ENV["RM_INFO"]
    # RubyMine internal debugger conflicts with ruby-debug. So, require it only when it's run outside of RubyMine
    gem "ruby-debug"   if version18 && !java_platform
    gem "ruby-debug19" if version19 && !java_platform
  end
end
