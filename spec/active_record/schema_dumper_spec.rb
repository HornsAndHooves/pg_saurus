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
        @dump.should =~ /create_schema "later"/
        @dump.should =~ /create_schema "latest"/
      end
      it 'dumps schemas in alphabetical order' do
        @dump.should =~ /create_schema "demography".*create_schema "later".*create_schema "latest"/m
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
        # added via standard add_index
        @dump.should =~ /add_index "users", \["name"\]/
        # added via foreign key
        @dump.should =~ /add_index "pets", \["user_id"\]/
        # foreign key :exclude_index
        @dump.should_not =~ /add_index "demography\.citizens", \["user_id"\]/
        # partial index
        @dump.should =~ /add_index "demography.citizens", \["country_id", "user_id"\].*:where => "active"/
      end

      # This index is added via add_foreign_key
      it 'dumps indexes from non-public schemas' do
        @dump.should =~ /add_index "demography.cities", \["country_id"\]/
      end

      it 'dumps functional indexes' do
        @dump.should =~ /add_index "pets", \["lower\(name\)"\]/
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
