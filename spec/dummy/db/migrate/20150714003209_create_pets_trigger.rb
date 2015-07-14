class CreatePetsTrigger < ActiveRecord::Migration
  def change
    create_function 'pets_not_empty_trigger_proc()', :trigger, <<-FUNCTION.gsub(/^[\s]{6}/, ""), schema: 'public'
      BEGIN
        RETURN null;
      END;
    FUNCTION

    # DROP TRIGGER trigger_pets_not_empty_trigger ON pets;
=begin
    execute <<-SQL
create CONSTRAINT trigger trigger_pets_not_empty_trigger
  after insert
  ON "pets"
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW
  EXECUTE PROCEDURE pets_not_empty_trigger();
    SQL
=end

    create_trigger :pets,
                   :pets_not_empty_trigger_proc,
                   'AFTER INSERT',
                   for_each: 'ROW',
                   schema: 'public',
                   constraint: true,
                   deferrable: true,
                   initially_deferred: true


    change_table :pets do |t|
      t.create_trigger :pets_not_empty_trigger_proc,
                       'AFTER INSERT',
                       name: 'trigger_foo'

      t.remove_trigger nil, name: 'trigger_foo'
    end
  end
end
