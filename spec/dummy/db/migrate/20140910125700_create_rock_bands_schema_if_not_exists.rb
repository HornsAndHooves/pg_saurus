class CreateRockBandsSchemaIfNotExists < ActiveRecord::Migration
  def change
    create_schema_if_not_exists(:rock_bands)
    # Should not raise exception even if the same schema exists
    create_schema_if_not_exists(:rock_bands)

    drop_schema_if_exists(:rock_bands)
    # Should not raise exception even the schema does not exist
    drop_schema_if_exists(:rock_bands)
  end
end
