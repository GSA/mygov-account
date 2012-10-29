class Api::TasksController < Api::ApiController
  
  def index
    unless @token.valid?
      render :json => {:status => 'Error', :message => "You do not have access to view tasks for that user."}, :status => 403
    else
      @tasks = @token.owner.tasks.where(:app_id => @token.authorization.client.owner.id)
      render :json => @tasks
    end
  end
  
  def create
    unless @token.valid?
      render :json => {:status => 'Error', :message => "You do not have access to create tasks for that user."}, :status => 403
    else
      @task = @token.owner.tasks.build((params[:task] || {}).merge(:app_id => @token.authorization.client.owner.id))
      if @task.save
        render :json => {:status => "OK", :task => @task }
      else
        render :json => {:status => "Error", :message => @task.errors }, :status => 400
      end
    end
  end
  
  def show
    unless @token.valid?
      render :json => {:status => 'Error', :message => "You do not have access to view tasks for that user."}, :status => 403
    else
      @task = @token.owner.tasks.find_by_id(params[:id])
      render :json => @task
    end      
  end
end