class AddCompoundFunctionalIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :pets, ["lower(color)", "lower(name)"]
  end
end
