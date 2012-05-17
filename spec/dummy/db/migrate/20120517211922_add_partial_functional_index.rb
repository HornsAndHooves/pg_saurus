class AddPartialFunctionalIndex < ActiveRecord::Migration
  def change
    add_index :pets, ["upper(color)"], :where => 'name IS NULL'
  end
end
