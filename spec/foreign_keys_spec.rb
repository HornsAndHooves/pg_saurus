describe 'Foreign keys' do
  describe '#add_foreign_key' do

    it 'adds foreign key' do
      PgPower::Explorer.has_foreign_key?('demography.citizens', :user_id).should be_true
    end

    it 'adds an index on the foreign key' do
      PgPower::Explorer.index_exists?('demography.citizens', :user_id).should be_true
    end

    it 'does not add an index on the foreign key when :exclude_index is true' do
      PgPower::Explorer.index_exists?('demography.cities', :country_id).should be_false
    end
  end
end
