class RenameNotificationTypeIdToNotificationType < ActiveRecord::Migration
  def change
    rename_column :notifications, :notification_type_id, :notification_type
    rename_column :notification_settings, :notification_type_id, :notification_type
  end

end
