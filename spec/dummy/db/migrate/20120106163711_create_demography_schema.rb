class CreateDemographySchema < ActiveRecord::Migration
  def change
    create_schema 'latest'
    create_schema 'demography'
    create_schema 'later'
  end
end
