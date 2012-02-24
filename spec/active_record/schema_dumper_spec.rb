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
    end

    context 'Tables' do
      it 'dumps tables' do
        @dump.should =~ /create_table "users"/
      end

      it 'dumps tables from non-public schemas' do
        @dump.should =~ /create_table "demography.citizens"/
      end
    end

    context 'Indexes' do
      it 'dumps indexes' do
        @dump.should =~ /add_index "users", \["name"\]/
      end

      it 'dumps indexes from non-public schemas' do
        @dump.should =~ /add_index "demography.citizens", \["country_id"\]/
      end

      # Double checking that indexes, created via add_foreign_key, are dumped
      it 'dumps foreign key indexes' do
        @dump.should =~ /add_index "demography.citizens", \["user_id"\]/
      end
    end

    context 'Foreign keys' do
      it 'dumps foreign keys' do
        @dump.should =~ /^\s*add_foreign_key "pets", "public.users", :name => "pets_user_id_fk"/
      end

      it 'dumps foreign keys from non-public schemas' do
        @dump.should =~ /^\s*add_foreign_key "demography.citizens", "public.users", :name => "demography_citizens_user_id_fk"/
        @dump.should =~ /add_foreign_key "demography.cities", "demography.countries"/
      end
    end

    context 'Comments' do
      it 'dumps table comments' do
        @dump.should =~ /set_table_comment 'users', 'Information about users'/
      end

      it 'dumps table comments from non-public schemas' do
        @dump.should =~ /set_table_comment 'demography.citizens', 'Citizens Info'/
      end

      it 'dumps column comments' do
        @dump.should =~ /set_column_comment 'users', 'name', 'User name'/
      end

      it 'dumps column comments from non-public schemas' do
        @dump.should =~ /set_column_comment 'demography.citizens', 'first_name', 'First name'/
      end
    end

  end
end
