require 'spec_helper'

describe 'Schema methods' do
  describe '#create_table' do
    context 'with :schema option' do
      it 'creates table in passed schema' do
        PgPower::Explorer.table_exists?('demography.population_statistics').should == true
      end
    end
  end

  describe '#drop_table' do
    context 'with :schema option' do
      # NOTE: this test makes sense only if create_table works as expected.
      it 'removes table in passed schema' do
        PgPower::Explorer.table_exists?('demography.nationalities').should == false
      end
    end
  end

  describe "#non_public_schema_tables" do
    is_superuser = ActiveRecord::Base.connection.
        select_value('select usesuper from pg_user where usename = current_user')

    if is_superuser == 't'
      pending("examples cannot run. " \
              "Revoke SUPERUSER privilege from user " \
              "'#{ActiveRecord::Base.connection.raw_connection.user}'"
      )
    else
      self.use_transactional_fixtures = false

      let(:connection) { ActiveRecord::Base.connection }

      def capture_stderr(&block)
        real_stderr, $stderr = $stderr, StringIO.new
        yield
        $stderr.string
      ensure
        $stderr = real_stderr
      end

      around do |example|
        begin
          connection.execute <<-SQL
          CREATE SCHEMA no_privileges;
          CREATE TABLE no_privileges.some_table();
          REVOKE USAGE ON SCHEMA no_privileges FROM #{connection.raw_connection.user};
          SQL

          example.call
        ensure
          connection.execute <<-SQL
          DROP SCHEMA no_privileges CASCADE
          SQL
        end
      end

      it "warns on attempt to dump inaccessible schema objects" do
        stream = StringIO.new

        stderr_result = capture_stderr{ ActiveRecord::SchemaDumper.dump(connection, stream) }
        stderr_result.
          should match(/ActiveRecord::InsufficientPrivilege:.+no_privileges\.some_table/)
      end
    end
  end

  describe '#move_table_to_schema' do
    it 'moves table to another schema' do
      PgPower::Explorer.table_exists?('public.people')    .should == false
      PgPower::Explorer.table_exists?('demography.people').should == true
    end
  end
end
