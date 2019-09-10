class AddForeignKeys < ActiveRecord::Migration[5.2]
  def change
    # Add foreign keys with indexes
    add_foreign_key 'pets', 'users'
    add_foreign_key 'pets', 'owners'
    add_foreign_key 'pets', 'breeds'
    add_foreign_key 'pets', 'demography.countries'
    add_foreign_key 'demography.citizens', 'demography.countries' # This foreign key is removed in RemoveForeignKeys migration

    # Add foreign key without an index
    add_foreign_key 'demography.citizens', 'users', exclude_index: true

  end
end
