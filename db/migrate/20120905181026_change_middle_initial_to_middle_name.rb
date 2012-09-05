class ChangeMiddleInitialToMiddleName < ActiveRecord::Migration
  def up
    rename_column :users, :middle_initial, :middle_name
  end

  def down
    rename_column :users, :middle_name, :middle_initial
  end
end
