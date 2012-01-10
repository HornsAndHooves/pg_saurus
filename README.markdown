# PgPower

ActiveRecord extension to get more from PostgreSQL.


## Migrations

In migrations you can use `create_schema` and `drop_schema` methods like this:

    class ReplaceDemographySchemaWithPolitics < ActiveRecord::Migration
      def change
        drop_schema 'demography'
        create_schema 'politics'
      end
    end

## Tools

PgPower::Tools provides number of useful methods:

    PgPower::Tools.create_schema "services"  # => create new PG schema "services"
    PgPower::Tools.create_schema "nets"
    PgPower::Tools.drop_schema "services"    # => remove the schema
    PgPower::Tools.schemas                   # => ["public", "information_schema", "nets"]

## Running tests:

* Configure `spec/dummy/config/database.yml` for development and test environments.
* Run `rake spec`.
* Make sure migrations don't raise exceptions and all specs pass.

## Copyright

* Copyright (c) 2012 TMX Credit.
* Author: Potapov Sergey.
