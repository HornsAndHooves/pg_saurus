module PgPower
  # :nodoc:
  module Generators
    # Generates config/initializers/pg_power.rb with default settings.
    class InstallGenerator < ::Rails::Generators::Base

      # :nodoc:
      desc <<-DESC
Description:
  Create default PgPower configuration
DESC

      source_root File.expand_path('../templates', __FILE__)

      # :nodoc:
      def copy_rails_files
        template "config/initializers/pg_power.rb"
      end

    end
  end
end
