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

require './lib/pg_saurus/version'

begin
  require "jeweler"

  Jeweler::Tasks.new do |gem|
    gem.name        = "pg_saurus"
    gem.summary     = "ActiveRecord extensions for PostgreSQL."
    gem.description = "ActiveRecord extensions for PostgreSQL. Provides useful tools for schema, foreign_key, index, function, trigger, comment and extension manipulations in migrations."
    gem.email       = ["blake131313@gmail.com", "arthur.shagall@gmail.com", "cryo28@gmail.com",
                       "matt.dressel@gmail.com", "rubygems.org@bruceburdick.com"]
    gem.authors     = ["Potapov Sergey", "Arthur Shagall", "Artem Ignatyev", "Matt Dressel", "Bruce Burdick", "HornsAndHooves"]
    gem.files       = Dir["{app,config,db,lib}/**/*"] + Dir['Rakefie', 'README.markdown']
    # Need to explicitly specify version here so gemspec:validate task doesn't whine.
    gem.version     = PgSaurus::VERSION
    gem.homepage    = "https://github.com/HornsAndHooves/pg_saurus"
    gem.license     = 'MIT'
  end
rescue
  puts "Jeweler or one of its dependencies is not installed."
end

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'PgSaurus'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

task 'spec' => ['db:drop', 'db:create', 'db:migrate', 'app:db:test:load']
