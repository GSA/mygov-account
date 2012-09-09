class CreateCriteriaForms < ActiveRecord::Migration
  def up
    create_table :criteria_forms, :id => false do |t|
      t.integer :criterium_id
      t.integer :form_id
    end
    add_index :criteria_forms, :criterium_id
    add_index :criteria_forms, :form_id
    add_index :criteria_forms, [:criterium_id, :form_id]
  end

  def down
    drop_table :criteria_forms
  end
end
