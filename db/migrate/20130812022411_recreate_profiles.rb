class RecreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :title, :limit => 10
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :suffix, :limit => 10
      t.string :name
      t.string :address
      t.string :address2
      t.string :city
      t.string :state, :limit => 5
      t.string :zip, :limit => 5
      t.date :date_of_birth
      t.string :phone, :limit => 12
      t.string :mobile, :limit => 12
      t.string :gender, :limit => 6
      t.string :marital_status, :limit => 15
      t.boolean :is_parent
      t.boolean :is_veteran
      t.boolean :is_student
      t.boolean :is_retired
      t.references :user

      t.timestamps
    end
    add_index :profiles, :user_id
  end
end
