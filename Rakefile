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

require 'lib/pg_power/version'

begin
  require "jeweler"

  Jeweler::Tasks.new do |gem|
    gem.name = "pg_power"
    gem.summary = "ActiveRecord extensions for PostgreSQL."
    gem.description = "ActiveRecord extensions for PostgreSQL. Provides useful tools and ability to create/drop schemas in migrations."
    gem.email = ["blake131313@gmail.com", "arthur.shagall@gmail.com"]
    gem.authors = ['Potapov Sergey', 'Arthur Shagall']
    gem.files = Dir["{app,config,db,lib}/**/*"] + Dir['Rakefie', 'README.markdown']
    # Need to explicitly specify version here so gemspec:validate task doesn't whine.
    gem.version = PgPower::VERSION
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

def gemspec
  @gem_spec ||= eval( open( `ls *.gemspec`.strip ){|file| file.read } )
end

def gem_version
  gemspec.version
end

def gem_version_tag
  "v#{gem_version}"
end

def gem_name
  gemspec.name
end

def gem_file_name
  "#{gem_name}-#{gem_version}.gem"
end

namespace :gemfury do
  desc "Build version #{gem_version} into the pkg directory and upload to GemFury"
  task :push => [:build] do
    sh "fury push pkg/#{gem_file_name} --as=TMXCredit"
  end
end

desc 'Run specs'
task 'spec' => ['db:drop', 'db:create', 'db:migrate', 'app:spec']
task :default => :spec
