class AddFormIdToTaskItemsAndAppIdToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :app_id, :integer
    add_column :task_items, :form_id, :integer
    add_index :tasks, :app_id
    add_index :task_items, :form_id
  end
end
