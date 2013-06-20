class DropProfileFieldsFromUsers < ActiveRecord::Migration
  def up
    [:title, :first_name, :middle_name, :last_name, :suffix, :name, :address, :address2, :city, :state, :zip, :date_of_birth, :phone, :mobile, :gender, :marital_status, :is_parent, :is_student, :is_veteran, :is_retired].map do |field|
      remove_column :users, field
    end
  end

  def down
    add_column :users, :title, :string, :limit => 10
    add_column :users, :first_name, :string
    add_column :users, :middle_name, :string
    add_column :users, :last_name, :string
    add_column :users, :suffix, :string, :limit => 10
    add_column :users, :name, :string
    add_column :users, :address, :string
    add_column :users, :address2, :string
    add_column :users, :city, :string
    add_column :users, :state, :string, :limit => 5
    add_column :users, :zip, :string, :limit => 5
    add_column :users, :date_of_birth, :date
    add_column :users, :phone, :string, :limit => 12
    add_column :users, :mobile, :string, :limit => 12
    add_column :users, :gender, :string, :limit => 6
    add_column :users, :marital_status, :string, :limit => 15
    add_column :users, :is_parent, :boolean
    add_column :users, :is_student, :boolean
    add_column :users, :is_veteran, :boolean
    add_column :users, :is_retired, :boolean
  end
end

