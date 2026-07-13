source "https://rubygems.org"

# To test against different rails versions with TravisCI
rails_version = ENV.fetch("RAILS_VERSION", "~> 8")

# NOTE: This is a Gemfile for a gem.

# 2017-01-12: Note: The GitHub pg mirror lacks the recent tags appearing in the Bitbucket Hg repo:
# https://github.com/ged/ruby-pg/blob/master/History.rdoc
# https://bitbucket.org/ged/ruby-pg/wiki/Home

gem "pg"
gem "psych"

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
