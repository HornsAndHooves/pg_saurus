# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150714003209) do

  create_schema "demography"
  create_schema "later"
  create_schema "latest"

  create_extension "fuzzystrmatch", :version => "1.0"
  create_extension "btree_gist", :schema_name => "demography", :version => "1.0"

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "fuzzystrmatch"
  enable_extension "btree_gist"

  create_table "breeds", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "demography.cities", force: :cascade do |t|
    t.integer "country_id"
    t.integer "name"
  end

  add_index "demography.cities", ["country_id"], :name => "index_demography_cities_on_country_id"

  create_table "demography.citizens", force: :cascade do |t|
    t.integer  "country_id"
    t.integer  "user_id"
    t.string   "first_name"
    t.string   "last_name"
    t.date     "birthday"
    t.text     "bio"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",     default: false, null: false
  end

  add_index "demography.citizens", ["country_id", "user_id"], :name => "index_demography_citizens_on_country_id_and_user_id", :unique => true, :where => "active"

  create_table "demography.countries", force: :cascade do |t|
    t.string   "name"
    t.string   "continent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "demography.people", force: :cascade do |t|
    t.string "name"
  end

  create_table "demography.population_statistics", force: :cascade do |t|
    t.integer "year"
    t.integer "population"
  end

  create_table "owners", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pets", force: :cascade do |t|
    t.string  "name"
    t.string  "color"
    t.integer "user_id"
    t.integer "country_id"
    t.integer "citizen_id"
    t.integer "breed_id"
    t.integer "owner_id"
    t.boolean "active",     default: true
  end

  add_index "pets", ["breed_id"], :name => "index_pets_on_breed_id"
  add_index "pets", ["color"], :name => "index_pets_on_color"
  add_index "pets", ["country_id"], :name => "index_pets_on_country_id"
  add_index "pets", ["lower(name)"], :name => "index_pets_on_lower_name"
  add_index "pets", ["to_tsvector('english'::regconfig, name)"], :name => "index_pets_on_to_tsvector_name_gist", :using => "gist"
  add_index "pets", ["upper(color)"], :name => "index_pets_on_upper_color", :where => "(name IS NULL)"
  add_index "pets", ["user_id"], :name => "index_pets_on_user_id"
  add_index "pets", ["user_id"], :name => "index_pets_on_user_id_gist", :using => "gist"

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["name"], :name => "index_users_on_name"

  add_foreign_key "demography.cities", "demography.countries", :exclude_index => true
  add_foreign_key "demography.citizens", "users", :exclude_index => true
  add_foreign_key "pets", "users", :exclude_index => true
  create_view "demography.citizens_view", <<-SQL
     SELECT citizens.id,
    citizens.country_id,
    citizens.user_id,
    citizens.first_name,
    citizens.last_name,
    citizens.birthday,
    citizens.bio,
    citizens.created_at,
    citizens.updated_at,
    citizens.active
   FROM demography.citizens;
  SQL

  create_function 'public.pets_not_empty()', :boolean, <<-FUNCTION_DEFINITION.gsub(/^[ ]{4}/, '')
    BEGIN
      IF (SELECT COUNT(*) FROM pets) > 0
      THEN
        RETURN true;
      ELSE
        RETURN false;
      END IF;
    END;
  FUNCTION_DEFINITION

  create_function 'public.pets_not_empty_trigger_proc()', :trigger, <<-FUNCTION_DEFINITION.gsub(/^[ ]{4}/, '')
    BEGIN
      RETURN null;
    END;
  FUNCTION_DEFINITION

  create_trigger 'pets', 'pets_not_empty_trigger_proc()', 'AFTER INSERT', name: 'trigger_pets_not_empty_trigger_proc', constraint: true, for_each: :row, deferrable: true, initially_deferred: false, schema: 'public', condition: '(new.name::text = \'fluffy\'::text)'

  set_table_comment 'demography.citizens', 'Citizens Info'
  set_column_comment 'demography.citizens', 'country_id', 'Country key'
  set_column_comment 'demography.citizens', 'first_name', 'First name'
  set_column_comment 'demography.citizens', 'last_name', 'Last name'

  set_column_comment 'demography.countries', 'name', 'Country name'

  set_table_comment 'users', 'Information about users'
  set_column_comment 'users', 'name', 'User name'
  set_column_comment 'users', 'email', 'Email address'
  set_column_comment 'users', 'phone_number', 'Phone number'

  set_index_comment 'demography.index_demography_citizens_on_country_id_and_user_id', 'Unique index on active citizens'
  set_index_comment 'index_pets_on_to_tsvector_name_gist', 'Functional index on name'

end
