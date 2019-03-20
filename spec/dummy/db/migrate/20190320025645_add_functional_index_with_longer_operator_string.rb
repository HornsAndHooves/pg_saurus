class AddFunctionalIndexWithLongerOperatorString < ActiveRecord::Migration
  def change
    add_index :pets, ["lower(name) DESC NULLS LAST"]
  end
end
