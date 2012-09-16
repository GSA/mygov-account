class TasksController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_user
  
  def show
    @task = @user.tasks.find_by_id(params[:id])
  end
  
  def update
    @task = @user.tasks.find_by_id(params[:id])
    @task.update_attributes(params[:task])
    if params[:completed]
      completed_at = Time.now
      @task.update_attributes(:completed_at => completed_at)
      @task.task_items.each{|task_item| task_item.update_attributes(:completed_at => completed_at)}
    end
    redirect_to dashboard_path
  end
  
  def destroy
    @task = @user.tasks.find_by_id(params[:id])
    @task.destroy
    redirect_to :back
  end
end
