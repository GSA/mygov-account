class AddFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :middle_initial, :string, :limit => 1
    add_column :users, :address, :string
    add_column :users, :address2, :string
    add_column :users, :city, :string
    add_column :users, :state, :string, :limit => 5
    add_column :users, :zip, :string, :limit => 5
    add_column :users, :ssn, :string, :limit => 9
    add_column :users, :date_of_birth, :date
    add_column :users, :phone, :string, :limit => 12
    add_column :users, :gender, :string, :limit => 6
    add_column :users, :marital_status, :string, :limit => 15
  end
end
