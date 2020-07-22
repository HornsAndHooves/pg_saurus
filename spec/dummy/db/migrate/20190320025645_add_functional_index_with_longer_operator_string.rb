class AddFunctionalIndexWithLongerOperatorString < ActiveRecord::Migration[5.2]
  def change
    add_index :pets, ["trim(lower(name)) DESC NULLS LAST"]
  end
end
