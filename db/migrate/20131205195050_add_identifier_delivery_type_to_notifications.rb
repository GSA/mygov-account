class AddIdentifierDeliveryTypeToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :identifier, :string
    add_column :notifications, :delivery_type, :string
  end
end
