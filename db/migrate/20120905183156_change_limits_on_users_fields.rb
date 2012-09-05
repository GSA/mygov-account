class ChangeLimitsOnUsersFields < ActiveRecord::Migration
  def up
    change_column :users, :state, :string, :limit => 5
    change_column :users, :zip, :string, :limit => 5
    change_column :users, :ssn, :string, :limit => 9
    change_column :users, :phone, :string, :limit => 12
    change_column :users, :gender, :string, :limit => 6
    change_column :users, :marital_status, :string, :limit => 15
  end

  def down
    change_column :users, :state, :string
    change_column :users, :zip, :string
    change_column :users, :ssn, :string
    change_column :users, :phone, :string
    change_column :users, :gender, :string
    change_column :users, :marital_status, :string
  end
end
