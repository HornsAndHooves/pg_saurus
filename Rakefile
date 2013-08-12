#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
begin
  require 'rdoc/task'
rescue LoadError
  require 'rdoc/rdoc'
  require 'rake/rdoctask'
  RDoc::Task = Rake::RDocTask
end

require './lib/pg_power/version'

begin
  require "jeweler"

  Jeweler::Tasks.new do |gem|
    gem.name = "pg_power"
    gem.summary = "ActiveRecord extensions for PostgreSQL."
    gem.description = "ActiveRecord extensions for PostgreSQL. Provides useful tools for schema, foreign_key, index, comment and extensios manipulations in migrations."
    gem.email = ["rubygems@tmxcredit.com"]
    gem.authors = ['Potapov Sergey', 'Arthur Shagall', 'Artem Ignatyev', 'TMX Credit']
    gem.files = Dir["{app,config,db,lib}/**/*"] + Dir['Rakefie', 'README.markdown']
    # Need to explicitly specify version here so gemspec:validate task doesn't whine.
    gem.version = PgPower::VERSION
    gem.homepage = "https://github.com/TMXCredit/pg_power"
  end
rescue
  puts "Jeweler or one of its dependencies is not installed."
end

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'PgPower'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task 'spec' => ['db:drop', 'db:create', 'db:migrate']
