class AddBooleanFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_parent, :boolean
    add_column :users, :is_veteran, :boolean
    add_column :users, :is_student, :boolean
    add_column :users, :is_retired, :boolean
  end
end
