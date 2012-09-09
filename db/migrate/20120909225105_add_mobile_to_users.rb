class AddMobileToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mobile, :string, :limit => 12
  end
end
