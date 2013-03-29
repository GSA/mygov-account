class RemoveProfiles < ActiveRecord::Migration
  def up
    drop_table :profiles
  end

  def down
    create_table "profiles", :force => true do |t|
      t.string   "title",                 :limit => 10
      t.string   "encrypted_first_name"
      t.string   "encrypted_middle_name"
      t.string   "encrypted_last_name"
      t.string   "suffix",                :limit => 10
      t.string   "encrypted_name"
      t.string   "encrypted_address"
      t.string   "encrypted_address2"
      t.string   "encrypted_city"
      t.string   "encrypted_state"
      t.string   "encrypted_zip"
      t.date     "date_of_birth"
      t.string   "encrypted_phone"
      t.string   "encrypted_mobile"
      t.string   "gender",                :limit => 6
      t.string   "marital_status",        :limit => 15
      t.boolean  "is_parent"
      t.boolean  "is_veteran"
      t.boolean  "is_student"
      t.boolean  "is_retired"
      t.integer  "user_id"
      t.datetime "created_at",                          :null => false
      t.datetime "updated_at",                          :null => false
    end
    add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id"
  end
end
