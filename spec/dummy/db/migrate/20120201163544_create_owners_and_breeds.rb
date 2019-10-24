class CreateOwnersAndBreeds < ActiveRecord::Migration[5.2]
  def change
    create_table :owners do |t|
      t.string :name

      t.timestamps
    end

    create_table :breeds do |t|
      t.string :name

      t.timestamps
    end
  end
end
