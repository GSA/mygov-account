class AddIndexToAuthentications < ActiveRecord::Migration
  def change
    remove_index :authentications, :uid
    add_index :authentications, [:uid, :provider]
  end
end
