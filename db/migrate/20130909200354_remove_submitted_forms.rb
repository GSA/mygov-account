class RemoveSubmittedForms < ActiveRecord::Migration
  def up
    drop_table :submitted_forms
    OauthScope.where(:scope_name => 'submit_forms').destroy_all
  end

  def down
    create_table "submitted_forms", :force => true do |t|
      t.integer  "user_id"
      t.integer  "app_id"
      t.string   "form_number"
      t.string   "data_url"
      t.datetime "created_at",  :null => false
      t.datetime "updated_at",  :null => false
    end
    add_index "submitted_forms", ["app_id"], :name => "index_submitted_forms_on_app_id"
    add_index "submitted_forms", ["user_id"], :name => "index_submitted_forms_on_user_id"
  end
end
