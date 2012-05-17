class AddFunctionalIndex < ActiveRecord::Migration
  def change
    add_index :pets, ["lower(name)"]
    # Ponder adding this to the test
    #add_index :pets, ["upper(color)"], :where => 'name IS NULL'
  end
end
