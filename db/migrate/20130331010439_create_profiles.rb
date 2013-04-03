class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :provider_name
      t.string :access_token
      t.references :user

      t.timestamps
    end
    add_index :profiles, :user_id
  end
end
