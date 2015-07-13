class AddFunctionCountPets < ActiveRecord::Migration
  def change
    create_function 'pets_not_empty()', :boolean, <<-FUNCTION, schema: 'public'
BEGIN
  IF (SELECT COUNT(*) FROM pets) > 0
  THEN
    RETURN true;
  ELSE
    RETURN false;
  END IF;
END;
    FUNCTION

    create_function 'public.foo_bar()', :boolean, <<-FUNCTION
BEGIN
  RETURN true;
END;
    FUNCTION

    drop_function 'foo_bar()'
  end
end
