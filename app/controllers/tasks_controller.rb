class TasksController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_user
  
  def index
    @page = [[(params[:page] || "1").to_i, (@user.tasks.uncompleted.count.to_f / 10).ceil].min, 1].max
    @tasks = @user.tasks.uncompleted.paginate(:page => @page, :per_page => 10)
  end
  
  def show
    @task = @user.tasks.find(params[:id])
  end
  
  def update
    @task = @user.tasks.find(params[:id])
    if @task
      @task.update_attributes(params[:task])
      @task.complete! if params[:completed]
    end
    redirect_to tasks_path(:page => params[:page])
  end
  
  def destroy
    @task = @user.tasks.find(params[:id])
    @task.destroy
    redirect_to tasks_path(:page => params[:page])
  end
end
