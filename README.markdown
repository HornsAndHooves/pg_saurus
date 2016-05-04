# PgSaurus

[![Build Status](https://secure.travis-ci.org/HornsAndHooves/pg_saurus.png)](http://travis-ci.org/HornsAndHooves/pg_saurus)
[![Code Climate](https://codeclimate.com/github/HornsAndHooves/pg_saurus/badges/gpa.svg)](https://codeclimate.com/github/HornsAndHooves/pg_saurus)

An ActiveRecord extension to get more from PostgreSQL:

* Create/drop schemas.
* Use existing functionality in the context of schemas.
* Set/remove comments on columns and tables.
* Use partial indexes.
* Run index creation concurrently.
* Create/drop views.
* Create/drop functions.
* Create/drop triggers.
* Load/unload postgres extensions.
* Select a specific DB role to conduct a migration.

PgSaurus is a fork of PgPower.

## Environment notes

PgSaurus v3 was tested with Rails 4.2, Ruby 2.2.4. For Rails 4.1, use PgSaurus v2.5+.

NOTE: JRuby is not supported. The current ActiveRecord JDBC adapter has its own Rails4-compatible
method named "create_schema" which conflicts with this gem.

## Schemas

### Create schema

In migrations you can use `create_schema` and `drop_schema` methods like this:

```ruby
class ReplaceDemographySchemaWithPolitics < ActiveRecord::Migration
  def change
    drop_schema 'demography'
    create_schema 'politics'

    drop_schema_if_exists('demography')
    create_schema_if_not_exists('politics')
  end
end
```
### Create table

Use schema `:schema` option to specify schema name:

```ruby
create_table "countries", :schema => "demography" do |t|
  # columns goes here
end
```
### Move table to another schema

Move table `countries` from `demography` schema to `public`:

```ruby
move_table_to_schema 'demography.countries', :public
```
## Table and column comments

Provides the following methods to manage comments:

* `set_table_comment(table_name, comment)`
* `remove_table_comment(table_name)`
* `set_column_comment(table_name, column_name, comment)`
* `remove_column_comment(table_name, column_name, comment)`
* `set_column_comments(table_name, comments)`
* `remove_column_comments(table_name, *comments)`


### Examples

Set a comment on the given table.

```ruby
set_table_comment :phone_numbers, 'This table stores phone numbers that conform to the North American Numbering Plan.'
```
Sets a comment on a given column of a given table.

```ruby
set_column_comment :phone_numbers, :npa, 'Numbering Plan Area Code - Allowed ranges: [2-9] for first digit, [0-9] for second and third digit.'
```
Removes any comment from the given table.

```ruby
remove_table_comment :phone_numbers
```
Removes any comment from the given column of a given table.

```ruby
remove_column_comment :phone_numbers, :npa
```
Set comments on multiple columns in the table.

```ruby
set_column_comments :phone_numbers, :npa => 'Numbering Plan Area Code - Allowed ranges: [2-9] for first digit, [0-9] for second and third digit.',
                                    :nxx => 'Central Office Number'
```
Remove comments from multiple columns in the table.

```ruby
remove_column_comments :phone_numbers, :npa, :nxx
```
PgSaurus also adds extra methods to change_table.

Set comments:

```ruby
change_table :phone_numbers do |t|
  t.set_table_comment 'This table stores phone numbers that conform to the North American Numbering Plan.'
  t.set_column_comment :npa, 'Numbering Plan Area Code - Allowed ranges: [2-9] for first digit, [0-9] for second and third digit.'
end

change_table :phone_numbers do |t|
  t.set_column_comments :npa => 'Numbering Plan Area Code - Allowed ranges: [2-9] for first digit, [0-9] for second and third digit.',
                        :nxx => 'Central Office Number'
end
```
Remove comments:

```ruby
change_table :phone_numbers do |t|
  t.remove_table_comment
  t.remove_column_comment :npa
end

change_table :phone_numbers do |t|
  t.remove_column_comments :npa, :nxx
end
```
## Foreign keys

PgSaurus v3 augments Rails 4.2's foreign key methods with:

* schema support
* index auto-generation

If you do not want to generate an index, pass the `exclude_index: true` option.

The syntax is compatible with Rails 4.2's foreign key handling methods.

Add foreign key from `comments` to `posts` using `post_id` column as key by default:

```ruby
add_foreign_key(:comments, :posts)
```
Specify key explicitly:

```ruby
add_foreign_key(:comments, :posts, :column => :blog_post_id)
```
Specify name of foreign key constraint:

```ruby
add_foreign_key(:comments, :posts, :name => "comments_posts_fk")
```
It works with schemas as expected:

```ruby
add_foreign_key('blog.comments', 'blog.posts')
```
Adds the index 'index_comments_on_post_id':

```ruby
add_foreign_key(:comments, :posts)
```
Does not add an index:

```ruby
add_foreign_key(:comments, :posts, :exclude_index => true)
```

### Migration notes

PgSaurus v3+ no longer provides `add_foreign_key`. That method is now handled by Rails 4.2+. A few things have changed.

## Partial Indexes

Rails 4.x [pull request](https://github.com/rails/rails/pull/4956) was used as a
starting point to patch it to be schema-aware.

### Examples

Add a partial index to a table

```ruby
add_index(:comments, [:country_id, :user_id], :where => 'active')
```
Add a partial index to a schema table

```ruby
add_index('blog.comments', :user_id, :where => 'active')
```
## Indexes on Expressions

PostgreSQL supports indexes on expressions. Right now, only basic functional
expressions are supported.

### Examples

Add an index to a column with a function

```ruby
add_index(:comments, "lower(text)")
```

You can also specify index access method

```ruby
create_extension 'btree_gist'
create_extension 'fuzzystrmatch'
add_index(:comments, 'dmetaphone(author)', :using => 'gist')
```

## Concurrent index creation

PostgreSQL supports concurent index creation. We added that feature to migration
DSL on index and foreign keys creation.

### Examples

Add an index concurrently to a table

```ruby
add_index :table, :column_id, :concurrently => true
```

Add an index concurrently along with foreign key

```ruby
add_foreign_key :table1, :table2, :column => :column_id, :concurrent_index => true
```

## Loading/Unloading postgresql extension modules

Postgresql is shipped with a number of [extension modules](http://www.postgresql.org/docs/9.1/static/contrib.html).
PgSaurus provides some tools
to [load](http://www.postgresql.org/docs/9.1/static/sql-createextension.html)/[unload](http://www.postgresql.org/docs/9.1/static/sql-dropextension.html)
such modules by the means of migrations.

Please note. CREATE/DROP EXTENSION command has been introduced in postgresql 9.1 only.
So this functionality will not be available for the previous versions.

### Examples

Load [fuzzystrmatch](http://www.postgresql.org/docs/9.1/static/fuzzystrmatch.html) extension module
and create its objects in schema *public*:

```ruby
create_extension "fuzzystrmatch"
```


Load version *1.0* of the [btree_gist](http://www.postgresql.org/docs/9.1/static/btree-gist.html) extension module
and create its objects in schema *demography*.

```ruby
create_extension "btree_gist", :schema_name => "demography", :version => "1.0"
```

Unload extension module:

```ruby
drop_extension "fuzzystrmatch"
```

## Views

Version 1.6.0 introduces experimental support for creating views. This API should only be used
with the understanding that it is preliminary 'alpha' at best.

### Example

```ruby
create_view "demography.citizens_view", "select * from demography.citizens"
```

## Roles

If you want to execute a migration as a specific PostgreSQL role you can use the `set_role` method:

```ruby
class CreateRockBands < ActiveRecord::Migration
  set_role "rocker"

  def change
    create_table :rock_bands do |t|
      # create columns
    end
  end
end
```

Technically it is equivalent to the following:

```ruby
class CreateRockBands < ActiveRecord::Migration
  def change
    execute "SET ROLE rocker"
    create_table :rock_bands do |t|
      # create columns
    end
  ensure
    execute "RESET ROLE"
  end
end
```

You may force all migrations to have `set_role`, for this, configure PgSaurus with
`ensure_role_set=true`:

```ruby
PgSaurus.configre do |config|
  config.ensure_role_set = true
end
```

## Functions

You can create, list, and drop functions.

### Examples

```ruby
# Create a function
pets_not_empty_function = <<-SQL
BEGIN
  IF (SELECT COUNT(*) FROM pets) > 0
  THEN
    RETURN true;
  ELSE
    RETURN false;
  END IF;
END;
SQL
# Arguments are: function_name, return_type, function_definition, options (currently, only :schema)
create_function 'pets_not_empty()', :boolean, pets_not_empty_function, schema: 'public'

# Drop a function
drop_function 'pets_not_empty()'

# Get a list of defined functions
ActiveRecord::Base.connection.functions
```

## Triggers

You can create and remove triggers on tables and views.

### Examples

```ruby
# Create a trigger
create_trigger :pets,                           # Table or view name
               :pets_not_empty_trigger_proc,    # Procedure name. Parentheses are optional if you have no arguments.
               'AFTER INSERT',                  # Trigger event
               for_each: 'ROW',                 # Can be row or statement. Default is row.
               schema: 'public',                # Optional schema name
               constraint: true,                # Sets if the trigger is a constraint. Default is false.
               deferrable: true,                # Sets if the trigger is immediate or deferrable. Default is immediate.
               initially_deferred: true,        # Sets if the trigger is initially deferred. Default is immediate. Only relevant if the trigger is deferrable.
               condition: "new.name = 'fluffy'" # Optional when condition. Default is none.

# Drop a trigger
remove_trigger :pets, :pets_not_empty_trigger_proc

# Get a list of defined triggers on a table or view
ActiveRecord::Base.connection.triggers
```

## Tools

PgSaurus::Tools provides a number of useful methods:

```ruby
PgSaurus::Tools.create_schema "services"                 # => create new PG schema "services"
PgSaurus::Tools.create_schema "nets"                     # => create new PG schema "nets"
PgSaurus::Tools.drop_schema "services"                   # => remove the PG schema "services"
PgSaurus::Tools.create_schema_if_not_exists "nets"       # => Does nothing -- schema "nets" already exists
PgSaurus::Tools.drop_schema_if_exists "services"         # => Does nothing -- schema "services" doesn't exist
PgSaurus::Tools.schemas                                  # => ["public", "information_schema", "nets"]
PgSaurus::Tools.index_exists?(table, columns, options)   # => returns true if an index exists for the given params
```

## Rails 3

PgSaurus does not support Rails 3.

## Running tests:

* Ensure your postgresql has postgres-contrib (Ubuntu) package installed. Tests depend on btree_gist and fuzzystrmatch extensions
 * If on Mac, see below for installing contrib packages
* Configure `spec/dummy/config/database.yml` for development and test environments.
* Run `rake spec`.
* Make sure migrations don't raise exceptions and all specs pass.

### Installing contrib packages on Mac OS X:
* This assumes you are using MacPorts to install Postgres.  If using homebrew or the Postgres App, you will need to adjust the instructions accordingly (please add to this README when you do)
* Assuming you installed with default options (including auto-clean), you will need to rebuild the postgresql port and keep the build files
 * `sudo port -k -s build postgresql91`
 * (adjust the version number above appropriately)
* Now you can make and install the btree_gist and any other contrib modules
 * `cd ```port work postgresql91```/postgresql-9.1.7/contrib/btree_gist`
 * (again, you may need to adjust the version number to your specific version)
 * `sudo make all`
 * `sudo make install`
* Done!

## TODO:

Support for Rails 4.2+

* This will likely necessitate a major rewrite.

Support for JRuby:

* Jdbc driver provides its own `create_schema(schema, user)` method - solve conflicts.

## Credits

* [Potapov Sergey](https://github.com/greyblake) - schema support
* [Arthur Shagall](https://github.com/albertosaurus) - function support - and thanks for [pg_comment](https://github.com/albertosaurus/pg_comment)
* [Matthew Higgins](https://github.com/matthuhiggins) - thanks for [foreigner](https://github.com/matthuhiggins/foreigner), which was used as a base for the foreign key support
* [Artem Ignatyev](https://github.com/cryo28) - extension modules load/unload support
* [Marcelo Silveira](https://github.com/mhfs) - thanks for rails partial index support that was backported into this gem

## Copyright and License

* Copyright (c) 2015 HornsAndHooves.
* Initial foreign key code taken from foreigner, Copyright (c) 2009 Matthew Higgins
* pg_comment Copyright (c) 2011 Arthur Shagall
* Partial index Copyright (c) 2012 Marcelo Silveira
* PgPower Copyright (c) 2012 TMX Credit.

Released under the MIT License.  See the MIT-LICENSE file for more details.

## Contributing

Contributions are welcome.  However, before issuing a pull request, please make sure of the following:

* All specs are passing (under ruby 1.9.3+)
* Any new features have test coverage.
* Anything that breaks backward compatibility has a very good reason for doing so.
