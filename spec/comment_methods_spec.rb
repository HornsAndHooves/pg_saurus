require 'spec_helper'

describe 'Comment methods' do

  describe '#set_table_comment' do
    it "sets comment on table" do
      comment = PgSaurus::Explorer.get_table_comment "users"
      comment.should == "Information about users"
    end

    it "sets comment on table of non-public schema" do
      comment = PgSaurus::Explorer.get_table_comment "demography.citizens"
      comment.should == "Citizens Info"
    end
  end

  describe '#set_column_comment' do
    it "sets comment on column"  do
      comment = PgSaurus::Explorer.get_column_comment "users", "name"
      comment.should == "User name"
    end

    it "sets comment on column of non-public schema" do
      comment = PgSaurus::Explorer.get_column_comment "demography.citizens", "country_id"
      comment.should == "Country key"
    end
  end

  describe '#set_column_comments' do
    it 'sets comments on columns' do
      PgSaurus::Explorer.get_column_comment("users", "email").should == "Email address"
      PgSaurus::Explorer.get_column_comment("users", "phone_number").should == "Phone number"
    end

    it "sets comments on columns of non-public schemas" do
      PgSaurus::Explorer.get_column_comment("demography.citizens", "first_name").
                        should == "First name"
      PgSaurus::Explorer.get_column_comment("demography.citizens", "last_name").
                        should == "Last name"
    end
  end

  describe '#set_index_comment' do
    it 'sets a comment on an index' do
      PgSaurus::Explorer.get_index_comment('index_pets_on_to_tsvector_name_gist').
                        should == 'Functional index on name'
    end

    it 'sets a comment on an index in a non-public schema' do
      PgSaurus::Explorer.get_index_comment('demography.index_demography_citizens_on_country_id_and_user_id').
                        should == 'Unique index on active citizens'

    end
  end

  # In migrations comments were set and then removed.
  # These tests suppose that #set_table_comment works as expected.
  describe '#remove_table_comment' do
    it 'removes comment on table' do
      PgSaurus::Explorer.get_table_comment("pets").should be_nil
    end

    it 'removes comment on table of non-public schema' do
      PgSaurus::Explorer.get_table_comment("demography.countries").should be_nil
    end
  end

  describe '#remove_column_comment' do
    it 'removes comment on column' do
      PgSaurus::Explorer.get_column_comment("demography.countries", "name").should == "Country name"
      PgSaurus::Explorer.get_column_comment("demography.countries", "continent").should be_nil
    end
  end

  describe '#remove_column_comments' do
    it 'removes comment on columns' do
      PgSaurus::Explorer.get_column_comment("demography.citizens", "bio").should be_nil
      PgSaurus::Explorer.get_column_comment("demography.citizens", "birthday").should be_nil
    end
  end

  describe '#remove_index_comment' do
    it 'removes comment on index' do
      PgSaurus::Explorer.get_index_comment('demography.index_demography_cities_on_country_id').
                        should be_nil
      PgSaurus::Explorer.get_index_comment('index_pets_on_breed_id').
                        should be_nil
    end
  end

end
