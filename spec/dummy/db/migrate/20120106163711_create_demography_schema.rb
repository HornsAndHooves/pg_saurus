class CreateDemographySchema < ActiveRecord::Migration[5.2]
  def change
    # do not change the order of these schema;
    # they are ordered this way to increase the likelihood of being dumped out of alphabetical order
    # if the sorting code breaks (triggering a test failure). -mike 20120306
    create_schema 'latest'
    create_schema 'demography'
    create_schema 'later'
  end
end
