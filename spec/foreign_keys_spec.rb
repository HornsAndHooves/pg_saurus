require 'spec_helper'

describe 'Foreign keys' do
  describe '#add_foreign_key' do
    # AddForeignKeys migration
    #   add_foreign_key 'pets', 'users'
    it 'adds foreign key' do
      PgSaurus::Explorer.has_foreign_key?('pets', :user_id).should == true
    end

    # AddForeignKeys migration
    #   add_foreign_key 'demography.citizens', 'users', :exclude_index => true
    it 'should not add an index on the foreign key when :exclude_index is true' do
      PgSaurus::Explorer.index_exists?('demography.citizens', :user_id).should == false
    end

    it 'should raise a PgSaurus::IndexExistsError when the index already exists' do
      expect {
        connection = ActiveRecord::Base::connection
        connection.add_index 'demography.citizens', :user_id
        connection.add_foreign_key 'demography.citizens', 'users'
      }.to raise_exception(PgSaurus::IndexExistsError)
    end
  end

  describe '#remove_foreign_key' do
    # RemoveForeignKeys migration
    #   remove_foreign_key 'demography.citizens', 'demography.countries'
    #   remove_foreign_key 'pets', :name => "pets_owner_id_fk"
    it 'removes foreign key' do
      PgSaurus::Explorer.has_foreign_key?('demography.citizens', :country_id).should == false
      PgSaurus::Explorer.has_foreign_key?('pets', :owner_id).should == false
    end

    # RemoveForeignKeys migration
    #   remove_foreign_key 'demography.citizens', 'demography.countries'
    #   remove_foreign_key 'pets', :name => "pets_owner_id_fk"
    it 'removes the index on the foreign key' do
      PgSaurus::Explorer.index_exists?('demography.citizens', :country_id).should == false
      PgSaurus::Explorer.index_exists?('pets', :owner_id).should == false
    end

    # RemoveForeignKeys migration
    #   remove_foreign_key 'pets', 'demography.countries', :exclude_index => true
    #   remove_foreign_key 'pets', :name => "pets_breed_id_fk", :exclude_index => true
    it 'should remove foreign key but not remove the index when :exclude_index is true' do
      PgSaurus::Explorer.has_foreign_key?('pets', :country_id).should == false
      PgSaurus::Explorer.has_foreign_key?('pets', :breed_id).should == false
      PgSaurus::Explorer.index_exists?('pets', :country_id).should == true
      PgSaurus::Explorer.index_exists?('pets', :breed_id).should == true
    end

    it 'should not raise an exception if the index does not exist' do
      expect {
        connection = ActiveRecord::Base::connection
        connection.add_foreign_key 'pets', 'demography.citizens', :exclude_index => true
        connection.remove_foreign_key 'pets', 'demography.citizens'
      }.not_to raise_error
    end
  end
end
