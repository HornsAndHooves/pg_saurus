class AddConcurrentlyIndexToUsersOnEmail < ActiveRecord::Migration[5.2]
  def change
    add_index :users, :email, :concurrently => true
  end
end
