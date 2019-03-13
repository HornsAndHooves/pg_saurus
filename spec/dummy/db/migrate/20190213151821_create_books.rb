class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :title

      t.timestamps
    end

    add_index :books, "title varchar_pattern_ops"

    set_table_comment :books, "Information about books"

    set_column_comment :books, :title, "Book title"
  end
end
