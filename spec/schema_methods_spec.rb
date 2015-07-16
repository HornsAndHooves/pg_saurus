require 'spec_helper'

describe 'Schema methods' do
  describe '#create_table' do
    context 'with :schema option' do
      it 'creates table in passed schema' do
        PgSaurus::Explorer.table_exists?('demography.population_statistics').should == true
      end
    end
  end

  describe '#drop_table' do
    context 'with :schema option' do
      # NOTE: this test makes sense only if create_table works as expected.
      it 'removes table in passed schema' do
        PgSaurus::Explorer.table_exists?('demography.nationalities').should == false
      end
    end
  end

  describe '#move_table_to_schema' do
    it 'moves table to another schema' do
      PgSaurus::Explorer.table_exists?('public.people')    .should == false
      PgSaurus::Explorer.table_exists?('demography.people').should == true
    end
  end
end
