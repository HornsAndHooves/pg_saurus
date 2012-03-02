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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120224204546) do

  create_schema "demography"

  create_table "pets", :force => true do |t|
    t.string  "name"
    t.integer "user_id"
    t.integer "country_id"
    t.integer "citizen_id"
  end

  add_index "pets", ["country_id"], :name => "index_pets_on_country_id"
  add_index "pets", ["user_id"], :name => "index_pets_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["name"], :name => "index_users_on_name"

  create_table "demography.citizens", :force => true do |t|
    t.integer  "country_id"
    t.integer  "user_id"
    t.string   "first_name"
    t.string   "last_name"
    t.date     "birthday"
    t.text     "bio"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",     :default => false, :null => false
  end

  add_index "demography.citizens", ["country_id", "user_id"], :name => "index_demography_citizens_on_country_id_and_user_id", :where => "active"

  create_table "demography.countries", :force => true do |t|
    t.string   "name"
    t.string   "continent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "demography.cities", :force => true do |t|
    t.integer "country_id"
    t.integer "name"
  end

  add_index "demography.cities", ["country_id"], :name => "index_demography_cities_on_country_id"

  set_table_comment 'users', 'Information about users'
  set_column_comment 'users', 'name', 'User name'
  set_column_comment 'users', 'email', 'Email address'
  set_column_comment 'users', 'phone_number', 'Phone number'

  set_table_comment 'demography.citizens', 'Citizens Info'
  set_column_comment 'demography.citizens', 'country_id', 'Country key'
  set_column_comment 'demography.citizens', 'first_name', 'First name'
  set_column_comment 'demography.citizens', 'last_name', 'Last name'

  set_column_comment 'demography.countries', 'name', 'Country name'

 add_foreign_key "demography.cities", "demography.countries", :name => "demography_cities_country_id_fk", :column => "country_id", :exclude_index => true

 add_foreign_key "demography.citizens", "public.users", :name => "demography_citizens_user_id_fk", :column => "user_id", :exclude_index => true

 add_foreign_key "pets", "public.users", :name => "pets_user_id_fk", :column => "user_id", :exclude_index => true

end
