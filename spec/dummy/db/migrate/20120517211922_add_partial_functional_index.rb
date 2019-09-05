class AddPartialFunctionalIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :pets, ["upper(color)"], :where => 'name IS NULL'
  end
end
