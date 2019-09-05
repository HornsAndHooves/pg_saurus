class AddFunctionalIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :pets, ["lower(name)"]
  end
end
