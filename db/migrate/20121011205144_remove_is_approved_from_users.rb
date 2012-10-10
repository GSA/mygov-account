class RemoveIsApprovedFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :is_approved
  end

  def down
    add_column :users, :is_approved, :boolean, :default => false, :null => false
    add_index :users, :is_approved
  end
end
