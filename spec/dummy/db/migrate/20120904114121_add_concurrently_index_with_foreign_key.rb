class AddConcurrentlyIndexWithForeignKey < ActiveRecord::Migration
  def change
    add_foreign_key :pets, :users, :exclude_index => true#, :concurrent_index => true
  end
end
