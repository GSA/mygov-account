class RemoveAppIdFromNotificationSettings < ActiveRecord::Migration
  def change
    remove_column :notification_settings, :app_id
  end

end
