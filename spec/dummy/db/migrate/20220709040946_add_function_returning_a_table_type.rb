class AddFunctionReturningATableType < ActiveRecord::Migration[6.1]
  def change
    create_function 'select_authors()', "TABLE (author_id INTEGER)", <<-FUNCTION.gsub(/^[\s]{6}/, ""), replace: false
      BEGIN
        RETURN query (
          SELECT author_id FROM books
        );
      END;
    FUNCTION
  end
end
