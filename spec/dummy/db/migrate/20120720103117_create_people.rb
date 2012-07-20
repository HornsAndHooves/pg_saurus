class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :name
    end
  end
end
