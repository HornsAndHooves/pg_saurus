class AddConcurrentlyIndexToUsersOnEmail < ActiveRecord::Migration
  def change
    add_index :users, :email, :concurrently => true
  end
end
