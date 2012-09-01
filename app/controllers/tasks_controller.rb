class TasksController < ApplicationController
  before_filter :authenticate_user!, :except => [:create]
  before_filter :assign_user, :except => [:create]
  before_filter :oauthorize, :only => [:create]
  
  def show
    @task = Task.find_by_id(params[:id])
  end
  
  def create
    unless @token.valid?
      render :json => {:status => 'Error', :message => "You do not have access to create tasks for that user."}, :status => 403
    else
      task = Task.new(params[:task])
      task.user_id = @user.id
      if task.save
        render :json => { :status => "OK", :message => "Task was successfully created", :task => task }
      else
        render :json => { :status => "Error", :message => task.errors}, :status => 400
      end
    end
  end

  def destroy
    @task = Task.find_by_id(params[:id])
    @task.destroy
    redirect_to :back
  end
end
