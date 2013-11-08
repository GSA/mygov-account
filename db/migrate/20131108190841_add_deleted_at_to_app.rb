class AddDeletedAtToApp < ActiveRecord::Migration
  def change
    add_column :apps, :deleted_at, :datetime
  end
end
