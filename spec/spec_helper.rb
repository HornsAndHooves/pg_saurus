ENV["RAILS_ENV"] ||= 'test'
# We probably don't want to use simplecov in Travis:CI, and we want to confirm
# simplecov exists (it won't in ruby 1.8.X)
if !ENV['TRAVIS']
  begin
    require 'simplecov'
  rescue LoadError
  end
end

require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'


Dir["#{File.expand_path('../', __FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
