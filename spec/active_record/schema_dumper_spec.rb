require 'spec_helper'

describe ActiveRecord::SchemaDumper do

  describe '.dump' do
    before(:all) do
      stream = StringIO.new
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, stream)
      @dump = stream.string
    end

    context 'Schemas' do
      it 'dumps schemas' do
        @dump.should =~ /create_schema "demography"/
      end

      it 'dumps tables from non public schemas' do
        @dump.should =~ /create_table "users"/
        @dump.should =~ /create_table "demography.citizens"/
        @dump.should =~ /create_table "demography.countries"/
      end

      it 'dumps indexes' do
        @dump.should =~ /add_index "users", \["name"\]/
        @dump.should =~ /add_index "demography\.citizens", \["country_id"\]/
        @dump.should =~ /add_index "demography\.citizens", \["user_id"\]/

        # verify that the dump includes standard add_index options
        @dump.should =~ /add_index "demography.citizens", \["country_id", "user_id"\].*:unique => true/
        # verify that the dump includes pg_power add_index options
        @dump.should =~ /add_index "demography.citizens", \["country_id", "user_id"\].*:where => "active"/
      end
    end

    context 'Foreign keys' do
      it 'dumps from public schema' do
        @dump.should =~ /^\s*add_foreign_key "pets", "public.users", :name => "pets_user_id_fk"/
      end

      it 'dumps from non public schemas' do
        @dump.should =~ /^\s*add_foreign_key "demography\.citizens", "public.users", :name => "demography_citizens_user_id_fk"/
        @dump.should =~ /add_foreign_key "demography.cities", "demography.countries"/

      end
    end

    context 'Comments' do
      it 'dumps table comments' do
        @dump.should =~ /set_table_comment 'users', 'Information about users'/
        @dump.should =~ /set_table_comment 'demography.citizens', 'Citizens Info'/
      end

      it 'dumps column comments' do
        @dump.should =~ /set_column_comment 'users', 'name', 'User name'/
        @dump.should =~ /set_column_comment 'demography.citizens', 'first_name', 'First name'/
      end
    end

  end
end
