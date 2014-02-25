class AddIdentifierDeliveryTypeToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :notification_type_id, :string
  end
end
