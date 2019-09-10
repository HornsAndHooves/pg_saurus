class AddConcurrentlyIndexWithForeignKey < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :pets, :users, exclude_index: true#, :concurrent_index => true
  end
end
