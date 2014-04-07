class AddCustomTextToApps < ActiveRecord::Migration
  def change
    add_column :apps, :custom_text, :string
  end
end
