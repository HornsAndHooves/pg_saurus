class AddConcurrentlyIndexToUsersOnEmail < ActiveRecord::Migration
  def change
    add_index :users, :email, :cuncurrently => true
  end
end
