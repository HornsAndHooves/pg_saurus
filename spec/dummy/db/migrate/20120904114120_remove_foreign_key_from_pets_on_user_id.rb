class RemoveForeignKeyFromPetsOnUserId < ActiveRecord::Migration
  def up
    remove_foreign_key :pets, :users
  end

  def down
    add_foreign_key :pets, :users
  end
end
