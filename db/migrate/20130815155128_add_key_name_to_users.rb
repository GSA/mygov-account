class AddKeyNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :key_storage_name, :string, :limit => 25
  end
end
