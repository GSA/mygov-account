class TaskItemsController < ApplicationController
  after_filter :complete_task
  
  def update
    @task_item = TaskItem.find(params[:id])
    @task_item.complete! if params[:completed]
    redirect_to task_path(@task_item.task)
  end
  
  def destroy
    @task_item = TaskItem.find(params[:id])
    @task_item.destroy
    redirect_to :back
  end
  
  private
  
  def complete_task
    @task_item.task.update_attributes(:completed_at => Time.now) if @task_item.task.task_items.uncompleted.size == 0
  end
end
