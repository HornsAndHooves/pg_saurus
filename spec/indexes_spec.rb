require 'spec_helper'

describe 'Indexes' do
  describe '#add_index' do
    it 'should be built with the :where option' do
      index_options = {:where => "active"}

      ActiveRecord::Migration.add_index(:pets, :name, index_options)

      PgSaurus::Explorer.index_exists?(:pets, :name, index_options).should be true
    end

    it 'should allow indexes with expressions using functions' do
      ActiveRecord::Migration.add_index(:pets, ["lower(name)", "lower(color)"])

      PgSaurus::Explorer.index_exists?(:pets, ["lower(name)", "lower(color)"] ).should be true
    end

    it 'should allow indexes with expressions using functions with multiple arguments' do
      ActiveRecord::Migration.add_index(:pets, "to_tsvector('english', name)", :using => 'gin')

      PgSaurus::Explorer.index_exists?(:pets, "gin(to_tsvector('english', name))" ).should be true
    end

    it 'should allow indexes with expressions using functions with multiple arguments as dumped' do
      ActiveRecord::Migration.add_index(:pets,
                                        "to_tsvector('english'::regconfig, name)",
                                        :using => 'gin')

      PgSaurus::Explorer.index_exists?(:pets, "gin(to_tsvector('english', name))" ).should be true
    end

    # TODO support this canonical example
    it 'should allow indexes with advanced expressions' do
      pending "Not sophisticated enough for this yet"
      ActiveRecord::Migration.add_index(:pets, ["(color || ' ' || name)"])

      PgSaurus::Explorer.index_exists?(:pets, ["(color || ' ' || name)"] ).should be true
    end

    it "should allow partial indexes with expressions" do
      opts = {:where => 'color IS NULL'}

      ActiveRecord::Migration.add_index(:pets, ['upper(name)', 'lower(color)'], opts)
      PgSaurus::Explorer.index_exists?(:pets, ['upper(name)', 'lower(color)'], opts).should be true
    end
  end

  describe '#remove_index' do
    it 'should remove indexes with expressions using functions' do
      ActiveRecord::Migration.add_index(:pets, ["lower(name)", "lower(color)"])
      ActiveRecord::Migration.remove_index(:pets, ["lower(name)", "lower(color)"])

      PgSaurus::Explorer.index_exists?(:pets, ["lower(name)", "lower(color)"] ).should be false
    end

    it 'should remove indexes built with the :where option' do
      pending "Looks like this isn't supported?"

      index_options = {:where => "active"}

      ActiveRecord::Migration.add_index(:pets, :name, index_options)
      ActiveRecord::Migration.remove_index(:pets, :name, index_options)

      PgSaurus::Explorer.index_exists?(:pets, :name, index_options).should be false
    end
  end

  describe '#index_exists' do
    it 'should be true for simple options' do
      PgSaurus::Explorer.index_exists?('pets', :color).should be true
    end

    it 'should support table name as a symbol' do
      PgSaurus::Explorer.index_exists?(:pets, :color).should be true
    end

    it 'should be true for simple options on a schema table' do
      PgSaurus::Explorer.index_exists?('demography.cities', :country_id).should be true
    end

    it 'should be true for a valid set of options' do
      index_options = {:unique => true, :where => 'active'}
      PgSaurus::Explorer.index_exists?('demography.citizens',
                                      [:country_id, :user_id],
                                      index_options
                                     ).should be true
    end

    it 'should be true for a valid set of options including name' do
      index_options = { :unique => true,
                        :where  => 'active',
                        :name   => 'index_demography_citizens_on_country_id_and_user_id' }
      PgSaurus::Explorer.index_exists?('demography.citizens',
                                      [:country_id, :user_id],
                                      index_options
                                     ).should be true
    end

    it 'should be false for a subset of valid options' do
      index_options = {:where => 'active'}
      PgSaurus::Explorer.index_exists?('demography.citizens',
                                      [:country_id, :user_id],
                                      index_options
                                     ).should be false
    end

    it 'should be false for invalid options' do
      index_options = {:where => 'active'}
      PgSaurus::Explorer.index_exists?('demography.citizens',
                                      [:country_id],
                                      index_options
                                     ).should be false
    end

    it 'should be true for a :where clause that includes boolean comparison' do
      index_options = {:where => 'active'}
      ActiveRecord::Migration.add_index(:pets, :name, index_options)
      PgSaurus::Explorer.index_exists?(:pets, :name, index_options).should be true
    end

    it 'should be true for a :where clause that includes text comparison' do
      index_options = {:where => "color = 'black'"}
      ActiveRecord::Migration.add_index(:pets, :name, index_options)
      PgSaurus::Explorer.index_exists?(:pets, :name, index_options).should be true
    end

    it 'should be true for a :where clause that includes NULL comparison' do
      index_options = {:where => 'color IS NULL'}
      ActiveRecord::Migration.add_index(:pets, :name, index_options)
      PgSaurus::Explorer.index_exists?(:pets, :name, index_options).should be true
    end

    it 'should be true for a :where clause that includes integer comparison' do
      index_options = {:where => 'id = 4'}
      ActiveRecord::Migration.add_index(:pets, :name, index_options)
      PgSaurus::Explorer.index_exists?(:pets, :name, index_options).should be true
    end

    it 'should be true for a compound :where clause' do
      index_options = {:where => "id = 4 and color = 'black' and active"}
      ActiveRecord::Migration.add_index(:pets, :name, index_options)
      PgSaurus::Explorer.index_exists?(:pets, :name, index_options).should be true
    end

    it 'should be true for concurrently created index' do
      index_options = {:concurrently => true}
      PgSaurus::Explorer.index_exists?(:users, :email, index_options).should be true
    end

  end
end
