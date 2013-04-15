class DropProfiles < ActiveRecord::Migration
  def up
    drop_table :profiles
  end

  def down
    create_table "profiles", :force => true do |t|
      t.string   "provider_name"
      t.string   "access_token"
      t.integer  "user_id"
      t.datetime "created_at",    :null => false
      t.datetime "updated_at",    :null => false
      t.string   "refresh_token"
      t.text     "data"
    end
    add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id"  
  end
end
