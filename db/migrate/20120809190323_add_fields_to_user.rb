class AddFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :middle_initial, :string, :length => 1
    add_column :users, :address, :string
    add_column :users, :address2, :string
    add_column :users, :city, :string
    add_column :users, :state, :string, :length => 5
    add_column :users, :zip, :string, :length => 5
    add_column :users, :ssn, :string, :length => 9
    add_column :users, :date_of_birth, :date
    add_column :users, :phone, :string, :length => 12
    add_column :users, :gender, :string, :length => 6
    add_column :users, :marital_status, :string, :length => 15
  end
end
