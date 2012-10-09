class LoadFuzzyStrMatchExtension < ActiveRecord::Migration
  def change
    create_extension "fuzzystrmatch"
  end
end
