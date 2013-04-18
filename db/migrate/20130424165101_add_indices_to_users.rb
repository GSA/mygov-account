class AddIndicesToUsers < ActiveRecord::Migration
  def change
    remove_index :users, :email
    add_index :users, :email, :unique => true
    add_index :users, [:uid, :provider], :unique => true
  end
end
