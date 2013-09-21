class AddProfileEncryptedToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :is_encrypted, :boolean, :default => false
  end
end
