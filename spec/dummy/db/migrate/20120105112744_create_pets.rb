class CreatePets < ActiveRecord::Migration[5.2]
  def change
    create_table :pets, comment: "Pets" do |t|
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
  end
end
