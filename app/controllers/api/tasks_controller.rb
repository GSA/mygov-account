class Api::TasksController < Api::ApiController
  before_filter :oauthorize_scope
  
  def index
    tasks = @user.tasks.where(:app_id => @app.id)
    render :json => tasks
  end
  
  def create
    task = @user.tasks.build(params[:task] || {})
    task.app_id = @app.id
    if task.save
      render :json => task
    else
      render :json => {:status => "Error", :message => task.errors }, :status => 400
    end
  end
  
  def show
    task = @token.owner.tasks.find_by_id(params[:id])
    render :json => task
  end
  
  protected
  
  def no_scope_message
    "You do not have access to #{self.action_name == 'create' ? 'create' : 'view'} tasks for that user."
  end
  
  def oauthorize_scope
    validate_oauth(OauthScope.find_by_scope_name('tasks'))
  end
end