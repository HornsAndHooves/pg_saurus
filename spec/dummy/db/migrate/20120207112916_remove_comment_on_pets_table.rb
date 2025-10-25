class RemoveCommentOnPetsTable < ActiveRecord::Migration[5.2]
  def up
    change_table_comment "pets", ""
  end

  def down
    change_table_comment "pets", "Pets"
  end
end
