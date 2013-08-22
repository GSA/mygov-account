class UpdateProfileColumnSizes < ActiveRecord::Migration
  def change
    change_column :profiles, :zip, :string, :limit => 25
    change_column :profiles, :state, :string, :limit => 25
    change_column :profiles, :phone, :string, :limit => 50
    change_column :profiles, :mobile, :string, :limit => 50
  end
end
