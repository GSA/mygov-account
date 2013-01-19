class AppsController < ApplicationController
  before_filter :get_current_user_apps, :only => [:index, :show]

  def get_current_user_apps
    @current_user_apps = current_user ? current_user.apps : []    
  end

  # GET /apps
  def index
    @apps = App.authentic_apps
  end
  
  # GET /apps/1
  def show
    @app = App.find_by_slug(params[:id])
  end
  
  def uninstall
    app = App.find_by_slug(params[:id])
    current_user.oauth2_authorizations.find{|oa| oa.client.owner == app}.destroy
    respond_to do |format|
      format.html { redirect_to app_path(app) }# index.html.erb
    end
  end
  
end