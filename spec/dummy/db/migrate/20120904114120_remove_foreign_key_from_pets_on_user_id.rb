class RemoveForeignKeyFromPetsOnUserId < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key :pets, :users
  end

  def down
    add_foreign_key :pets, :users
  end
end
