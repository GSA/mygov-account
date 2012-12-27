class AppsController < ApplicationController
  before_filter :get_current_user_apps, :only => [:index, :show]

  def get_current_user_apps
    @current_user_apps = current_user ? current_user.apps : []    
  end

  # GET /apps
  def index
    @apps = App.all
  end
  
  # GET /apps/1
  def show
    @app = App.find_by_slug(params[:id])
  end
end