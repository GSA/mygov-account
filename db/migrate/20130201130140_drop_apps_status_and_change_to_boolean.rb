class DropAppsStatusAndChangeToBoolean < ActiveRecord::Migration
  def up
    add_column :apps, :is_public, :boolean, :default => false
    remove_column :apps, :status
  end

  def down
    remove_column :apps, :is_public
    add_column :apps, :status, :string, :default => "sandbox"
  end
end
