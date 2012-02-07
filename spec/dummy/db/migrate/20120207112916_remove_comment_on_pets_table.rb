class RemoveCommentOnPetsTable < ActiveRecord::Migration
  def up
    remove_table_comment "pets"
  end

  def down
    set_table_comment "pets", "Pets"
  end
end
