class CreateExtension < ActiveRecord::Migration
  def change
    create_extension "fuzzystrmatch"
    drop_extension "fuzzystrmatch", :mode => :cascade
    create_extension "fuzzystrmatch"

    # Test names with dashes are escaped correctly.
    # https://github.com/TMXCredit/pg_power/pull/40
    create_extension "uuid-ossp"
    drop_extension   "uuid-ossp"

    create_extension "btree_gist", :schema_name => 'demography'
    add_index :pets, :user_id, :using => :gist, :name => 'index_pets_on_user_id_gist'
    add_index :pets, "to_tsvector('english', name)", :using => :gist, :name => 'index_pets_on_to_tsvector_name_gist'
  end
end
