class CreateDeliveryTypes < ActiveRecord::Migration
  def change
    create_table :delivery_types do |t|
      t.integer :notification_id
      t.string :name

      t.timestamps
    end
  end
end
