class AddConcurrentlyIndexWithForeignKey < ActiveRecord::Migration
  def change
    add_foreign_key :pets, :users, :exclude_index => false, :concurent_index => true
  end
end
