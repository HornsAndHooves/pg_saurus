module PgPower
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      desc <<-DESC
Description:
  Create default PgPower configuration
DESC

      source_root File.expand_path('../templates', __FILE__)

      def copy_rails_files
        template "config/initializers/pg_power.rb"
      end
    end
  end
end
