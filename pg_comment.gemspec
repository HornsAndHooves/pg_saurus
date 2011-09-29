# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pg_comment/version"

Gem::Specification.new do |s|
  s.name        = "pg_comment"
  s.version     = PgComment::VERSION
  s.authors     = ["Arthur Shagall"]
  s.email       = ["arthur.shagall@gmail.com"]
  s.homepage    = "https://github.com/albertosaurus/pg_comment"
  s.summary     = 'Postgres Comments for Rails'
  s.description = 'Extends Rails migrations to support setting column and table comments.  Pulls out comments into schema.rb'

  s.rubyforge_project = "pg_comment"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('activerecord', '>= 3.0.0')
  s.add_development_dependency("test-unit")
end
