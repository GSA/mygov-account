class RenameIdentifierToNotificationTypeId < ActiveRecord::Migration
  def change
    rename_column :notifications, :identifier, :notification_type_id
  end
end
