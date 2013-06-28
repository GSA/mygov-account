class CreateAppActivityLogs < ActiveRecord::Migration
  def change
    create_table :app_activity_logs do |t|
      t.belongs_to :app
      t.belongs_to :user
      t.string :controller
      t.string :action
      t.string :description

      t.timestamps
    end
  end
end
