class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :title
      t.json :tags

      t.timestamps
    end

    add_index :books, "title varchar_pattern_ops"

    add_index :books, "((tags->'attrs'->>'edition')::int)", name: "books_tags_json_index", skip_column_quoting: true

    set_table_comment :books, "Information about books"

    set_column_comment :books, :title, "Book title"
  end
end
