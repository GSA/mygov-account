class CreateTaskItems < ActiveRecord::Migration
  def change
    create_table :task_items do |t|
      t.string :name
      t.string :url
      t.datetime :completed_at
      t.references :task

      t.timestamps
    end
    add_index :task_items, :task_id
  end
end
