class CreatePets < ActiveRecord::Migration
  def change
    create_table :pets do |t|
      t.string :name
      t.string :color
      t.integer :user_id
      t.integer :country_id
      t.integer :citizen_id
      t.integer :breed_id
      t.integer :owner_id
      t.boolean :active, default: true
    end

    add_index(:pets, :color)

    set_table_comment :pets, "Pets"
  end
end
