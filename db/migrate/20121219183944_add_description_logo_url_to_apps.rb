class AddDescriptionLogoUrlToApps < ActiveRecord::Migration
  def change
    add_column :apps, :description, :text
    add_column :apps, :short_description, :string
    add_column :apps, :url, :string
    add_attachment :apps, :logo
  end
end
