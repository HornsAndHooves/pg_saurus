source "https://rubygems.org"

# To test against different rails versions with TravisCI
rails_version = ENV['RAILS_VERSION'] || '~> 4.0'

# NOTE: This is a Gemfile for a gem.
# Using 'platforms' is contraindicated because they won't make it into
# the gemspec correctly.
version19 = (RUBY_VERSION =~ /^1\.9/)
version18 = (RUBY_VERSION =~ /^1\.8/)

gem 'pg'

gem 'rails', rails_version

group :development do
  gem 'rspec-rails'

  # code metrics:
  gem 'rcov' if version18
  gem 'yard'
  gem 'metrical' , :require => false if version18
  gem 'metric_fu', :require => false unless version18
  gem 'jeweler', :require => false


  unless ENV["RM_INFO"]
    # RubyMine internal debugger conflicts with ruby-debug. So, require it only when it's run outside of RubyMine
    gem "ruby-debug"   if version18
    gem "ruby-debug19" if version19
  end
end

group :development, :test do
  gem 'pry'
end

group :test do
  # Only load simplecov for Ruby 1.9+, use rcov above for 1.8.
  unless version18
    gem 'simplecov'          , :require => false
    gem 'simplecov-rcov-text', :require => false
  end
end
