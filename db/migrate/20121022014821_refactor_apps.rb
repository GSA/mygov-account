class RefactorApps < ActiveRecord::Migration
  def up
    drop_table :criteria
    drop_table :forms
    drop_table :criteria_forms
    remove_column :pdfs, :form_id
    remove_column :task_items, :form_id
  end

  def down
    add_column :task_items, :form_id, :integer
    add_index "task_items", ["form_id"], :name => "index_task_items_on_form_id"
    
    add_column :pdfs, :form_id, :integer
    add_index "pdfs", ["form_id"], :name => "index_pdfs_on_form_id"
    
    create_table "criteria", :force => true do |t|
      t.string   "label"
      t.integer  "app_id"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end
    add_index "criteria", ["app_id"], :name => "index_criteria_on_app_id"

    create_table "criteria_forms", :id => false, :force => true do |t|
      t.integer "criterium_id"
      t.integer "form_id"
    end
    add_index "criteria_forms", ["criterium_id", "form_id"], :name => "index_criteria_forms_on_criterium_id_and_form_id"
    add_index "criteria_forms", ["criterium_id"], :name => "index_criteria_forms_on_criterium_id"
    add_index "criteria_forms", ["form_id"], :name => "index_criteria_forms_on_form_id"
    
    create_table "forms", :force => true do |t|
      t.string   "url"
      t.string   "name"
      t.string   "call_to_action"
      t.integer  "app_id"
      t.datetime "created_at",     :null => false
      t.datetime "updated_at",     :null => false
      t.string   "agency"
    end
    add_index "forms", ["app_id"], :name => "index_forms_on_app_id"
  end
end