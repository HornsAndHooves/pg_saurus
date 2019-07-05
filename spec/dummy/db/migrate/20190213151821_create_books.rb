class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.integer :author_id
      t.integer :publisher_id
      t.string :title
      t.json :tags

      t.timestamps
    end

    add_index :books, ["author_id DESC NULLS FIRST", "publisher_id DESC NULLS LAST"],
              name: "books_author_id_and_publisher_id"

    add_index :books, "title varchar_pattern_ops"

    add_index :books, "((tags->'attrs'->>'edition')::int)", name: "books_tags_json_index", skip_column_quoting: true

    set_table_comment :books, "Information about books"

    set_column_comment :books, :title, "Book title"
  end
end
