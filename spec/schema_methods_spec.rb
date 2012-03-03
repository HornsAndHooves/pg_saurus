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
    # NOTE: this test have a sense only of create_table works as expected.
      it 'removes table in passed schema' do
        PgPower::Explorer.table_exists?('demography.nationalities').should == false
      end
    end
  end
end