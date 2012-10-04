class AddIsApprovedToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_approved, :boolean, :default => false, :null => false
    add_index :users, :is_approved
  end
end
