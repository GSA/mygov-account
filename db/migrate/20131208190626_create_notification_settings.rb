class CreateNotificationSettings < ActiveRecord::Migration
  def change
    create_table :notification_settings do |t|
      t.integer :user_id
      t.integer :app_id
      t.text :delivery_type
      t.integer :notification_type_id

      t.timestamps
    end
  end
end
