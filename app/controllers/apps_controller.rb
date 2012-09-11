class AppsController < ApplicationController
  before_filter :assign_app
  before_filter :save_session_info, :except => [:show]
  
  def show
    session["app_name"] = @app.slug
  end
  
  def start
    if params[:app].nil?
      flash[:error] = "Please select at least one reason."
      redirect_to :back
    else
      @criteria = params[:app].collect{|param| param.first }
    end
  end
  
  def info
    @user = User.new
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
  
  def forms
    if current_user
      redirect_to dashboard_path
    else
      @user = User.new(params[:user])
      @criteria = session[:app].collect{|param| param.first }
    end
  end
  
  private
  
  def assign_app
    @app = App.find_by_slug(params[:id])
  end
  
  def save_session_info
    session["app"] = {} unless session["app"]
    session["app"].merge!(params[:app]) if params[:app]
    session["user"] = {} unless session["user"]
    session["user"].merge!(params[:user]) if params[:user]
  end
end