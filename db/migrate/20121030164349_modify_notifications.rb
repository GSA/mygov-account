class ModifyNotifications < ActiveRecord::Migration
  def up
    #remove_index :notifications, :o_auth2_model_client_id
    rename_column :notifications, :o_auth2_model_client_id, :app_id
    add_index :notifications, :app_id
  end
  
  def down
    remove_index :notifications, :app_id
    rename_column :notifications, :app_id, :o_auth2_model_client_id
    add_index :notifications, :o_auth2_model_client_id
  end    
end
