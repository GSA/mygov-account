class TaskItemsController < ApplicationController
  
  def destroy
    @task_item = TaskItem.find_by_id(params[:id])
    @task_item.destroy
    @task_item.task.update_attributes(:completed_at => Time.now) if @task_item.task.task_items.uncompleted.size == 0
    redirect_to :back
  end
end
