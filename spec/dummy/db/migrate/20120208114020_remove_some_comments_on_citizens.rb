class RemoveSomeCommentsOnCitizens < ActiveRecord::Migration
  def up
    remove_column_comments 'demography.citizens', :birthday, :bio
  end

  def down
    set_column_comments 'demography.citizens',
      :birthday   => "Birthday",
      :bio        => "Biography"
  end
end
