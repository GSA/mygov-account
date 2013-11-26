class DropNameFromProfiles < ActiveRecord::Migration
  def up
    remove_column :profiles, :name
  end

  def down
    add_column :profiles, :name, :string
  end
end
