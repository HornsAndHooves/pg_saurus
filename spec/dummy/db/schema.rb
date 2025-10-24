# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2022_07_09_040946) do
  create_schema_if_not_exists "demography"
  create_schema_if_not_exists "later"
  create_schema_if_not_exists "latest"

  create_extension "fuzzystrmatch", version: "1.2"
  create_extension "btree_gist", schema_name: "demography", version: "1.7"

  create_schema_if_not_exists "demography"
  create_schema_if_not_exists "later"
  create_schema_if_not_exists "latest"

  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "fuzzystrmatch"
  enable_extension "plpgsql"

  create_function 'public.pets_not_empty()', 'boolean', <<-FUNCTION_DEFINITION.gsub(/^[ ]{4}/, ''), volatility: :volatile
    BEGIN
      IF (SELECT COUNT(*) FROM pets) > 0
      THEN
        RETURN true;
      ELSE
        RETURN false;
      END IF;
    END;
  FUNCTION_DEFINITION

  create_function 'public.pets_not_empty_trigger_proc()', 'trigger', <<-FUNCTION_DEFINITION.gsub(/^[ ]{4}/, ''), volatility: :immutable
    BEGIN
      RETURN null;
    END;
  FUNCTION_DEFINITION

  create_function 'public.select_authors()', 'TABLE(author_id integer)', <<-FUNCTION_DEFINITION.gsub(/^[ ]{4}/, ''), volatility: :volatile
    BEGIN
      RETURN query (
        SELECT author_id FROM books
      );
    END;
  FUNCTION_DEFINITION

  create_table "books", comment: "Information about books", force: :cascade do |t|
    t.integer "author_id"
    t.integer "publisher_id"
    t.string "title", comment: "Book title"
    t.json "tags"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index "((((tags -> 'attrs'::text) ->> 'edition'::text))::integer)", name: "books_tags_json_index", skip_column_quoting: true
    t.index ["author_id", "publisher_id"], name: "books_author_id_and_publisher_id", order: { author_id: :desc, publisher_id: "DESC NULLS LAST" }
    t.index ["title"], name: "index_books_on_title_varchar_pattern_ops", opclass: :varchar_pattern_ops
  end

  create_table "breeds", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "demography.cities", force: :cascade do |t|
    t.integer "country_id"
    t.integer "name"
    t.index ["country_id"], name: "index_demography_cities_on_country_id"
  end

  create_table "demography.citizens", comment: "Citizens Info", force: :cascade do |t|
    t.integer "country_id", comment: "Country key"
    t.integer "user_id"
    t.string "first_name", comment: "First name"
    t.string "last_name", comment: "Last name"
    t.date "birthday"
    t.text "bio"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "active", default: false, null: false
    t.index ["country_id", "user_id"], name: "index_demography_citizens_on_country_id_and_user_id", unique: true, where: "active", comment: "Unique index on active citizens"
  end

  create_table "demography.countries", force: :cascade do |t|
    t.string "name", comment: "Country name"
    t.string "continent"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "demography.people", force: :cascade do |t|
    t.string "name"
  end

  create_table "demography.population_statistics", force: :cascade do |t|
    t.integer "year"
    t.integer "population"
  end

  create_table "owners", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "pets", force: :cascade do |t|
    t.string "name"
    t.string "color"
    t.integer "user_id"
    t.integer "country_id"
    t.integer "citizen_id"
    t.integer "breed_id"
    t.integer "owner_id"
    t.boolean "active", default: true
    t.index "TRIM(BOTH FROM lower(name)) DESC NULLS LAST", name: "index_pets_on_lower_name_desc_nulls_last"
    t.index "lower(name)", name: "index_pets_on_lower_name"
    t.index "to_tsvector('english'::regconfig, name)", name: "index_pets_on_to_tsvector_name_gist", using: :gist, comment: "Functional index on name"
    t.index "upper(color)", name: "index_pets_on_upper_color", where: "(name IS NULL)"
    t.index ["breed_id"], name: "index_pets_on_breed_id"
    t.index ["color"], name: "index_pets_on_color"
    t.index ["country_id"], name: "index_pets_on_country_id"
    t.index ["lower(color)", " lower(name)"], name: "index_pets_on_lower_color_and_lower_name"
    t.index ["user_id"], name: "index_pets_on_user_id"
    t.index ["user_id"], name: "index_pets_on_user_id_gist", using: :gist
  end

  create_table "users", comment: "Information about users", force: :cascade do |t|
    t.string "name", comment: "User name"
    t.string "email", comment: "Email address"
    t.string "phone_number", comment: "Phone number"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["name"], name: "index_users_on_name"
  end

  add_foreign_key "demography.cities", "demography.countries", exclude_index: true
  add_foreign_key "demography.citizens", "users", exclude_index: true
  add_foreign_key "pets", "users", exclude_index: true
  create_view "demography.citizens_view", <<-SQL
     SELECT id,
    country_id,
    user_id,
    first_name,
    last_name,
    birthday,
    bio,
    created_at,
    updated_at,
    active
   FROM demography.citizens;
  SQL

  set_table_comment 'books', 'Information about books'
  set_column_comment 'books', 'title', 'Book title'

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

  create_trigger 'pets', 'pets_not_empty_trigger_proc()', 'AFTER INSERT', name: 'trigger_pets_not_empty_trigger_proc', constraint: true, for_each: :row, deferrable: true, initially_deferred: false, schema: 'public', condition: '(new.name::text = \'fluffy\'::text)'

end
