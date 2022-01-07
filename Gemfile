source "https://rubygems.org"

# To test against different rails versions with TravisCI
rails_version = ENV["RAILS_VERSION"] || "~> 6.0"

# NOTE: This is a Gemfile for a gem.
# Using "platforms" is contraindicated because they won't make it into
# the gemspec correctly.
version2x = (RUBY_VERSION =~ /^2\.\d/)

# 2017-01-12: Note: The GitHub pg mirror lacks the recent tags appearing in the Bitbucket Hg repo:
# https://github.com/ged/ruby-pg/blob/master/History.rdoc
# https://bitbucket.org/ged/ruby-pg/wiki/Home

gem "pg"
gem "psych", "~> 3"

gem "railties",      rails_version
gem "activemodel",   rails_version
gem "activerecord",  rails_version
gem "activesupport", rails_version

group :development do
  gem "rspec-rails"

  # code metrics:
  gem "yard"
  gem "metric_fu", require: false
  gem "jeweler"  , require: false


  unless ENV["RM_INFO"]
    # debugger does not support Ruby 2.x:
    # ref: https://github.com/cldwalker/debugger/issues/125#issuecomment-43353446
    gem "byebug"       if version2x
  end
end

group :development, :test do
  gem "pry"
  gem "pry-byebug"
  gem "rubocop"
end

group :test do
  gem "simplecov"          , require: false
  gem "simplecov-rcov-text", require: false
end
