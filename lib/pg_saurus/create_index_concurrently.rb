# Adds ability to configure in migration how index will be created.
# See more details how to create index concurrently in PostgreSQL at
# (see http://www.postgresql.org/docs/9.2/static/sql-createindex.html#SQL-CREATEINDEX-CONCURRENTLY).
#
# There are several things you should be aware when use option to create index
# concurrently.
# Index can not be created concurrently inside transaction and such indexes
# creation will be postponed till migration transaction will be closed.
# In case of migration failure and transaction was rolled back indexes will not
# be created concurrently. But if indexes which should be created concurrently
# run with errors migration's transaction won't be rolled back. Error in that
# case will be raised and migration process will be stoped.
#
# Migrations can not ensure that all indexes that tend to be created
# concurrently were created even if the query for such index creation run
# without errors. Such indexes creation are deferred because of its nature.
# So, it's up to you to ensure that indexes was really created or remove
# partially created invalid indexes.
#
# :concurrent_index option conflicts with :exclude_index option in method
# `add_foreign_key`. So, if you put them together exception will be raised.
#
# @example
#
#   class AddIndexToNameForUsers < ActiveRecord::Migration
#     def change
#       add_index :users, :name, :concurrently => true
#     end
#   end
#
#   # or with foreign key
#
#   class AddForeignKeyToRoleIdForUsers < ActiveRecord::Migration
#     def change
#       add_foreign_key :users, :roles, :concurrent_index => true
#     end
#   end
#
module PgSaurus::CreateIndexConcurrently
  # Provides ability to postpone index creation queries in migrations.
  #
  # Overrides `add_index` and `add_foreign_key` methods for migration to be
  # able to prevent indexes creation inside scope of transaction if they have to
  # be created concurrently.
  # Allows to run creation of postponed indexes.
  #
  # This module included into ActiveRecord::Migration class to extend it with
  # new features.
  #
  # All postponed index creation queries are stored inside migration instance.
  module Migration
    # @attribute postponed_queries
    #   @return [Array] list of arguments to call `add_index` method.
    # @private
    attr_accessor :postponed_queries
    private :postponed_queries, :postponed_queries=


    # Add a new index to the table. +column_name+ can be a single Symbol, or
    # an Array of Symbols.
    #
    # @param [Symbol, String]                        table_name
    # @param [Symbol, String, Array<Symbol, String>] column_name
    # @param [optional, Hash]                        options
    # @option options [Boolean] :unique
    # @option options [Boolean] :concurrently
    # @option options [String]  :where
    #
    # @return [nil]
    #
    # @see ActiveRecord::ConnectionAdapters::SchemaStatements.add_index in pg_saurus gem
    def add_index(table_name, column_name, options = {}, &block)
      table_name = proper_table_name(table_name)
      # GOTCHA:
      #   checks if index should be created concurretnly then put it into
      #   the queue to wait till queue processing will be called (should be
      #   happended after closing transaction).
      #   Otherwise just delegate call to PgSaurus's `add_index`.
      #   Block is given for future compatibility.
      #   -- zekefast 2012-09-12
      unless options[:concurrently]
        return connection.add_index(table_name, column_name, options, &block)
      end

      enque(table_name, column_name, options, &block)
      nil
    end

    # Execute all postponed index creation.
    #
    # @return [::PgSaurus::CreateIndexConcurrently::Migration]
    def process_postponed_queries
      Array(@postponed_queries).each do |arguments, block|
        connection.add_index(*arguments, &block)
      end

      clear_queue

      self
    end

    # Clean postponed queries queue.
    #
    # @return [::PgSaurus::CreateIndexConcurrently::Migration] migration
    def clear_queue
      @postponed_queries = []

      self
    end
    private :clear_queue

    # Add to the queue add_index call parameters to be able execute call later.
    #
    # @param [Array] arguments
    # @param [Proc]  block
    #
    # @return [::PgSaurus::CreateIndexConcurrently::Migration]
    def enque(*arguments, &block)
      @postponed_queries ||= []
      @postponed_queries << [arguments, block]

      self
    end
    private :enque
  end

  # Allows `process_postponed_queries` to be called on MigrationProxy instances.
  # So, (see ::PgSaurus::CreateIndexConcurrently::Migrator) could run index
  # creation concurrently.
  #
  # Default delegation in (see ActiveRecord::MigrationProxy) allows to call
  # only several methods.
  module MigrationProxy
    # :nodoc:
    def self.included(klass)
      klass.delegate :process_postponed_queries, :to => :migration
    end
  end

  # Run postponed index creation for each migration.
  #
  # This module included into (see ::ActiveRecord::Migrator) class to make possible
  # to execute queries for postponed index creation after closing migration's
  # transaction.
  #
  # @see ::ActiveRecord::Migrator.migrate
  # @see ::ActiveRecord::Migrator.ddl_transaction
  module Migrator
    extend ActiveSupport::Concern

    # :nodoc:
    def self.included(klass)
      klass.alias_method_chain :ddl_transaction, :postponed_queries
    end

    # Override (see ::ActiveRecord::Migrator.ddl_transaction) to call
    # (see ::PgSaurus::CreateIndexConcurrently::Migration.process_postponed_queries)
    # immediately after transaction.
    #
    # @see ::ActiveRecord::Migrator.ddl_transaction
    def ddl_transaction_with_postponed_queries(*args, &block)
      ddl_transaction_without_postponed_queries(*args, &block)

      # GOTCHA:
      #   This might be a bit tricky, but I've decided that this is the best
      #   way to retrieve migration instance after closing transaction.
      #   The problem that (see ::ActiveRecord::Migrator) doesn't provide any
      #   access to recently launched migration. All logic to iterate through
      #   set of migrations incapsulated in (see ::ActiveRecord::Migrator.migrate)
      #   method.
      #   So, to get access to migration you need to override `migrate` method
      #   and duplicated all logic inside it, plus add call to
      #   `process_postponed_queries`.
      #   I've decided this is less forward compatible then retrieving
      #   value of `migration` variable in context where block
      #   given to `ddl_transaction` method was created.
      #   -- zekefast 2012-09-12
      migration = block.binding.eval('migration')
      migration.process_postponed_queries
    end
  end
end
