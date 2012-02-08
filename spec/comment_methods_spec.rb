require 'spec_helper'

describe 'Comment methods' do

  describe '#set_table_comment' do
    it "sets comment on table" do
      comment = PgCommentGetter.get_table_comment "users"
      comment.should == "Information about users"
    end

    it "sets comment on non public schema table" do
      comment = PgCommentGetter.get_table_comment "demography.citizens"
      comment.should == "Citizens Info"
    end
  end


  describe '#set_column_comment' do
    it "sets comment on column"  do
      comment = PgCommentGetter.get_column_comment "users", "name"
      comment.should == "User name"
    end

    it "sets comment on column of non public schema"  do
      comment = PgCommentGetter.get_column_comment "demography.citizens", "country_id"
      comment.should == "Country key"
    end
  end


  describe '#set_column_tables' do
    it 'sets comments on columns' do
      PgCommentGetter.get_column_comment("users", "email").should == "Email address"
      PgCommentGetter.get_column_comment("users", "phone_number").should == "Phone number"
    end

    it "sets comments on columns of non public schemas" do
      PgCommentGetter.get_column_comment("demography.citizens", "first_name").should == "First name"
      PgCommentGetter.get_column_comment("demography.citizens", "last_name").should == "Last name"
    end
  end


  # In migrations comments were set and then removed. 
  # These tests suppose that #set_table_comment works as expected.
  describe '#remove_table_comment' do
    it 'removes comment on table' do
      PgCommentGetter.get_table_comment("pets").should be_nil
    end

    it 'removes comment on table of non public schema' do
      PgCommentGetter.get_table_comment("demography.countries").should be_nil
    end
  end

  describe '#remove_column_comment' do
    it 'removes comment on column' do
      PgCommentGetter.get_column_comment("demography.countries", "name").should == "Country name"
      PgCommentGetter.get_column_comment("demography.countries", "continent").should be_nil
    end
  end

  describe '#remove_column_comments' do
    it 'removes comment on columns' do
      PgCommentGetter.get_column_comment("demography.citizens", "bio").should be_nil
      PgCommentGetter.get_column_comment("demography.citizens", "birthday").should be_nil
    end

  end

end
