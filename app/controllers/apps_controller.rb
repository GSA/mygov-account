class AppsController < ApplicationController
  before_filter :assign_app
  before_filter :set_app_session_data, :only => [:start]
  before_filter :set_user_session_data
  before_filter :set_form_action, :only => [:info, :address, :birthdate, :contact_info]
  before_filter :assign_user, :only => :finish
  
  def show
  end
  
  def start
    session["user"] = nil
    if params[:app].nil?
      flash[:error] = "Please select at least one reason."
      redirect_to :back
    else
      @criteria = params[:app].collect{|param| param.first }
      @button_to_path = current_user ? review_app_path(@app) : info_app_path(@app)
    end
  end
  
  def info
    @user = User.new(params[:user])
  end
  
  def address
    @user = User.new(params[:user])
  end
  
  def birthdate
    @user = User.new(params[:user])
  end
  
  def contact_info
    @user = User.new(params[:user])
  end
  
  def review
    @user = User.new(session["user"])
  end
  
  def forms
    @user = User.new(session["user"]) 
    @criteria = session["app"].collect{|param| param.first }
    @update_profile = params[:update_profile]
  end
  
  def save
    if current_user
      redirect_to finish_app_path(@app, :update_profile => params[:update_profile])
    else
      session[:user_return_to] = finish_app_path(@app, :update_profile => "1")
    end
  end
  
  def finish
    if params[:update_profile] == "1"
      user_attributes = session["user"].reject{|k,v| k == "email"}
      @user.update_attributes(user_attributes)
    end
    task = @user.tasks.create(:app_id => @app.id)
    criteria = session["app"].collect{|k,v| k }
    forms = @app.find_forms_by_criteria(criteria)
    forms.each do |form|
      task.task_items.create(:form_id => form.id)
    end
    redirect_to task_path(task)
  end
  
  private
  
  def assign_app
    @app = App.find_by_slug(params[:id])
    session["app_name"] = @app.slug
  end
  
  def set_app_session_data
    session["app"] = {}
    session["app"].merge!(params[:app]) if params[:app]
  end

  def set_user_session_data
    if session["user"].nil?
      session["user"] = (current_user ? current_user.profile_attributes : {})
    else
      session["user"].merge!(params[:user]) if params[:user]
    end
  end
  
  def set_form_action
    @action_path = review_app_path(@app) if request.env['HTTP_REFERER'] =~ /^.*\/#{@app.slug}\/review$/
  end
end