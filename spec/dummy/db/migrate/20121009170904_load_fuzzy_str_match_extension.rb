class LoadFuzzyStrMatchExtension < ActiveRecord::Migration
  def change
    create_extension "fuzzystrmatch"

    create_extension "cube"
    drop_extension "cube", :mode => :cascade

    create_extension "cube", :schema_name => 'demography'
  end
end
