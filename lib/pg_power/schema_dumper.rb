module PgPower
  # Extends ActiveRecord::SchemaDumper class to dump schemas other than "public"
  # and tables from those schemas.
  module SchemaDumper
    extend ActiveSupport::Concern

    included do
      alias_method_chain :tables, :schemas
      alias_method_chain :tables, :comments
    end

    # * Dumps schemas.
    # * Dumps tables from public schema using native #tables method.
    # * Dumps tables from schemas other than public.
    def tables_with_schemas(stream)
      schemas(stream)
      tables_without_schemas(stream)
      non_public_schema_tables(stream)
    end

    # Generates code to create schemas.
    def schemas(stream)
      # Don't create "public" schema since it exists by default.
      schema_names = PgPower::Tools.schemas - ["public", "information_schema"]
      schema_names.each do |schema|
        schema(schema, stream)
      end
      stream << "\n"
    end
    private :schemas

    # Generates code to create schema.
    def schema(schema_name, stream)
      stream << "  create_schema \"#{schema_name}\"\n"
    end
    private :schema

    # Dumps tables from schemas other than public
    def non_public_schema_tables(stream)
      get_non_public_schema_table_names.each do |name|
        table(name, stream)
      end
    end
    private :non_public_schema_tables

    # Returns the list of non public schema tables
    # Usage:
    #   get_non_public_schema_table_names # => ['demography.countries', 'demography.cities', 'politics.members']
    def get_non_public_schema_table_names
      result = @connection.query(<<-SQL, 'SCHEMA')
        SELECT schemaname || '.' || tablename
        FROM pg_tables
        WHERE schemaname NOT IN ('pg_catalog', 'information_schema', 'public')
      SQL
      result.flatten
    end
    private :get_non_public_schema_table_names





    def tables_with_comments(stream)
      tables_without_comments(stream)

      table_names = @connection.tables.sort
      table_names += get_non_public_schema_table_names.sort

      table_names.each do |table_name|
        dump_comments(table_name, stream)
      end
    end

    def dump_comments(table_name, stream)
      unless (comments = @connection.comments(table_name)).empty?
        comment_statements = comments.map do |row|
          column_name = row[0]
          comment = row[1].gsub(/'/, "\\\\'")
          if column_name
            "  set_column_comment '#{table_name}', '#{column_name}', '#{comment}'"
          else
            "  set_table_comment '#{table_name}', '#{comment}'"
          end

        end

        stream.puts comment_statements.join("\n")
        stream.puts
      end
    end
    private :dump_comments

  end
end
