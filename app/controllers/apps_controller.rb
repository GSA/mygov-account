class AppsController < ApplicationController
  before_filter :assign_app
  before_filter :save_session_info, :except => [:show]
  
  def show
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
    @user = User.new(params[:user])
  end
  
  private
  
  def assign_app
    @app = App.find_by_slug(params[:id])
  end
  
  def save_session_info
    session["app"] = {} unless session["app"]
    session["app"].merge!(params[:app]) if params[:app]
  end
end