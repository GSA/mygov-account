class CreateNotificationSettings < ActiveRecord::Migration
  def change
    create_table :notification_settings do |t|
      t.integer :user_id
      t.text :delivery_type
      t.string :notification_type_id

      t.timestamps
    end
  end
end
