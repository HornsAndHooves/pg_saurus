class CreatePets < ActiveRecord::Migration
  def change
    create_table :pets do |t|
      t.string :name
    end

    set_table_comment :pets, "Pets"
  end
end
