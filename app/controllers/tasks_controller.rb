class TasksController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_user
  
  def show
    @task = @user.tasks.find_by_id(params[:id])
  end
  
  def destroy
    @task = @user.tasks.find_by_id(params[:id])
    @task.destroy
    redirect_to :back
  end
end
