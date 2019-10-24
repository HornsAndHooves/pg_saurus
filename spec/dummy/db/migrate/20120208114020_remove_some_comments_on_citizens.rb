class RemoveSomeCommentsOnCitizens < ActiveRecord::Migration[5.2]
  def up
    remove_column_comments 'demography.citizens', :birthday, :bio
  end

  def down
    set_column_comments 'demography.citizens',
      birthday: "Birthday",
      bio:      "Biography"
  end
end
