module PgPower::CreateIndexConcurrently
  module Migration
    attr_accessor :postponed_queries


    def add_index(table_name, column_name, options = {}, &block)
      table_name = ::ActiveRecord::Migrator.proper_table_name(table_name)
      unless options[:concurrently]
        return connection.add_index(table_name, column_name, options, &block)
      end

      enque(table_name, column_name, options, &block)
    end

    # Adds foreign key.
    #
    # @raise [ArgumentError] in case of conflicted option were set
    # Adds foreign key.
    #
    # Ensures that an index is created for the foreign key, unless :exclude_index is true.
    #
    # == Options:
    # * :column
    # * :primary_key
    # * :dependent
    # * :exclude_index    [Boolean]
    # * :concurrent_index [Boolean]
    #
    # @param [String, Symbol]          from_table
    # @param [String, Symbol]          to_table
    # @param [Hash]                    options
    # @option options [String, Symbol] :column
    # @option options [String, Symbol] :primary_key
    # @option options [Hash]           :dependent
    # @option options [Boolean]        :exclude_index
    # @option options [Boolean]        :concurrent_index
    #
    # @raise [PgPower::IndexExistsError] when :exclude_index is true, but the index already exists
    def add_foreign_key(from_table, to_table, options = {}, &block)
      from_table = ::ActiveRecord::Migrator.proper_table_name(from_table)
      if options[:concurrent_index]
        if options[:exclude_index]
          raise ArgumentError, 'Conflicted options(exclude_index, concurrent_index) was found, both are set to true.'
        end

        options[:column] ||= connection.id_column_name_from_table_name(to_table)
        options = options.merge(:concurrently => options[:concurrent_index])
        enque(from_table, options[:column], options)
      end

      connection.add_foreign_key(from_table, to_table, options, &block)
    end

    def process_postponed_queries
      result = Array(@postponed_queries).each do |arguments, block|
        connection.add_index(*arguments, &block)
      end

      clean_queue

      result
    end

    # Clean postponed queries' queue.
    #
    # @return [::PgPower::CreateIndexConcurrently::Migration] migration
    def clean_queue
      @postponed_queries = []

      self
    end
    private :clean_queue

    def enque(*arguments, &block)
      @postponed_queries ||= []
      @postponed_queries << [arguments, block]
    end
    private :enque
  end

  module MigrationProxy
    def self.included(klass)
      klass.delegate :process_postponed_queries, :to => :migration
    end
  end

  module Migrator
    extend ActiveSupport::Concern

    def self.included(klass)
      klass.alias_method_chain :ddl_transaction, :postponed_queries
    end

    def ddl_transaction_with_postponed_queries(*args, &block)
      ddl_transaction_without_postponed_queries(*args, &block)

      migration = block.binding.eval('migration')
      migration.process_postponed_queries
    end
  end
end
