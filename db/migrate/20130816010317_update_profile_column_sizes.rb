class UpdateProfileColumnSizes < ActiveRecord::Migration
  def change
    change_column :profiles, :zip, :string, :limit => 50
    change_column :profiles, :phone, :string, :limit => 100
    change_column :profiles, :mobile, :string, :limit => 100
  end
end
