class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :phone_number

      t.timestamps
    end

    add_index(:users, :name)

    set_table_comment :users, "Information about users"

    set_column_comment :users, :name, "User name"

    set_column_comments :users,
      :email        => "Email address",
      :phone_number => "Phone number"
  end
end
