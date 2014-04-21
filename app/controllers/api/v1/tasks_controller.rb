class Api::V1::TasksController < Api::ApiController
  before_filter :oauthorize_scope

  def index
    tasks = @user.tasks.where(:app_id => @app.id).joins(:task_items)
    render :json => tasks.to_json(:include => :task_items), :status => 200
  end

  def create
    task = @user.tasks.build(params[:task] || {})
    task.app_id = @app.id
    if task.save
      render :json => task.to_json(:include => :task_items), :status => 200
    else
      render :json => {:message => task.errors}, :status => 400
    end
  end

  def show
    task = @token.owner.tasks.find_by_id(params[:id])
    render :json => task.to_json(:include => :task_items), :status => 200
  end

  def update
    begin
      task = @user.tasks.find(params[:id])
      if task
        task.assign_attributes(params[:task], :as => :admin)
        task.complete! if params[:task][:completed]
        task.save
      end
      render :json => task.to_json(:include => :task_items)
    rescue ActiveRecord::RecordNotFound
      render :json => { :message => "Invalid parameters. Check your values and try again."}, :status => 422
    end
  end

  protected

  def no_scope_message
    "You do not have permission to #{self.action_name == 'create' ? 'create' : 'view'} tasks for that user."
  end

  def oauthorize_scope
    validate_oauth(OauthScope.find_all_by_scope_name('tasks'))
  end
end