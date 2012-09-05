class AddTitleAndSuffixToUsers < ActiveRecord::Migration
  def change
    add_column :users, :title, :string, :limit => 10
    add_column :users, :suffix, :string, :limit => 10
  end
end
