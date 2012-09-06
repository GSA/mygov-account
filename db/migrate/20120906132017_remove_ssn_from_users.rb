class RemoveSsnFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :ssn
  end

  def down
    add_column :users, :ssn, :string, :limit => 9
  end
end
