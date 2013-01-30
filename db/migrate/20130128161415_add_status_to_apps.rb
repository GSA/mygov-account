class AddStatusToApps < ActiveRecord::Migration
  def change
    add_column :apps, :status, :string
    App.reset_column_information
    App.update_all(status: "public")
  end
end
