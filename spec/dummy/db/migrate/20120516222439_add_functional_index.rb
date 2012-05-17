class AddFunctionalIndex < ActiveRecord::Migration
  def change
    add_index :pets, ["lower(name)"]
  end
end
