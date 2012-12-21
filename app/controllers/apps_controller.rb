class AppsController < ApplicationController
  before_filter :only => [:show, :launch]

  # GET /apps
  def index
    @apps = App.all
    @current_user_apps = current_user ? current_user.apps : []
  end
  
  # GET /apps/1
  def show
    @app = App.find_by_slug(params[:id])
  end
end