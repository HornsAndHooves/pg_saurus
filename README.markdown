# PgPower

ActiveRecord extension to get more from PostgreSQL:

* Create/drop schemas.
* Set/remove comments on columns and tables.
* Use foreign keys.
* Use partial indexes.

## Environment notes

It was tested with Rails 3.1.3 and Ruby 1.8.7.


## Schemas

### Create schema

In migrations you can use `create_schema` and `drop_schema` methods like this:

    class ReplaceDemographySchemaWithPolitics < ActiveRecord::Migration
      def change
        drop_schema 'demography'
        create_schema 'politics'
      end
    end

### Create table

Use schema prefix in you table name:

    create_table "demography.countries" do |t|
      # columns goes here
    end

## Comments

Provides next methods to manage comments:

* set\_table\_comment(table\_name, comment)
* remove\_table\_comment(table\_name)
* set\_column\_comment(table\_name, column\_name, comment)
* remove\_column\_comment(table\_name, column\_name, comment)
* set\_column\_comments(table\_name, comments)
* remove\_column\_comments(table\_name, *comments)


### Examples

Set a comment on the given table.

    set_table_comment :phone_numbers, 'This table stores phone numbers that conform to the North American Numbering Plan.'

Sets a comment on a given column of a given table.

    set_column_comment :phone_numbers, :npa, 'Numbering Plan Area Code - Allowed ranges: [2-9] for first digit, [0-9] for second and third digit.'

Removes any comment from the given table.

    remove_table_comment :phone_numbers

Removes any comment from the given column of a given table.

    remove_column_comment :phone_numbers, :npa

Set comments on multiple columns in the table.

    set_column_comments :phone_numbers, :npa => 'Numbering Plan Area Code - Allowed ranges: [2-9] for first digit, [0-9] for second and third digit.',
                                        :nxx => 'Central Office Number'

Remove comments from multiple columns in the table.

    remove_column_comments :phone_numbers, :npa, :nxx

PgPower also adds extra methods to change_table.

Set comments:

    change_table :phone_numbers do |t|
        t.set_table_comment 'This table stores phone numbers that conform to the North American Numbering Plan.'
        t.set_column_comment :npa, 'Numbering Plan Area Code - Allowed ranges: [2-9] for first digit, [0-9] for second and third digit.'
    end

    change_table :phone_numbers do |t|
        t.set_column_comments :npa => 'Numbering Plan Area Code - Allowed ranges: [2-9] for first digit, [0-9] for second and third digit.',
                              :nxx => 'Central Office Number'
    end

Remove comments:

    change_table :phone_numbers do |t|
        t.remove_table_comment
        t.remove_column_comment :npa
    end

    change_table :phone_numbers do |t|
      t.remove_column_comments :npa, :nxx
    end

## Foreign keys

We imported some code of [foreigner](https://github.com/matthuhiggins/foreigner)
gem and patched it to be schema-aware. So you should disable `foreigner` in your
Gemfile if you want to use `pg_power`.

The syntax is compatible with `foreigner`:


Add foreign key from `comments` to `posts` using `post_id` column as key by default:
    add_foreign_key(:comments, :posts)

Specify key explicitly:
    add_foreign_key(:comments, :posts, :column => :blog_post_id)

Specify name of foreign key constraint:
    add_foreign_key(:comments, :posts, :name => "comments_posts_fk")

It works with schemas as expected:
    add_foreign_key('blog.comments', 'blog.posts')

## Partial Indexes

We used a Rails 4.x [pull request](https://github.com/rails/rails/pull/4956) as a
starting point, backported to Rails 3.1.x and patched it to be schema-aware.

### Examples

Add a partial index to a table

    add_index(:comments, [:country_id, :user_id], :where => 'active')

Add a partial index to a schema table

    add_index('blog.comments', :user_id, :where => 'active')

## Tools

PgPower::Tools provides number of useful methods:

    PgPower::Tools.create_schema "services"                 # => create new PG schema "services"
    PgPower::Tools.create_schema "nets"                     # => create new PG schema "nets"
    PgPower::Tools.drop_schema "services"                   # => remove the PG schema "services"
    PgPower::Tools.schemas                                  # => ["public", "information_schema", "nets"]
    PgPower::Tools.index_exists?(table, columns, options)   # => returns true if an index exists for the given params

## Running tests:

* Configure `spec/dummy/config/database.yml` for development and test environments.
* Run `rake spec`.
* Make sure migrations don't raise exceptions and all specs pass.

## TODO:

Add next syntax to create table:

    create_table "table_name", :schema => "schema_name" do |t|
      # columns goes here
    end

Support for JRuby:

* Jdbc driver provides its own `create_schema(schema, user)` method - solve conflicts.

## Credits

* [Potapov Sergey](https://github.com/greyblake) - schema support
* [Arthur Shagall](https://github.com/albertosaurus) - thanks for [pg_comment](https://github.com/albertosaurus/pg_comment)

## Copyright

Copyright (c) 2012 TMX Credit.
