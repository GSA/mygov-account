class AppsController < ApplicationController
  before_filter :get_current_user_apps, :only => [:index, :show, :edit]
  before_filter :verify_app_owner,  :only =>  [:edit, :update]
  before_filter :verify_public_or_is_owner, :only => [:show]
  before_filter :authenticate_user!, :only => [:new]

  # Ensure that only public apps and sandbox apps owned by current user can be viewed.
  def verify_public_or_is_owner
    return true if App.find_by_slug(params[:id]).has_owner?(current_user) || !App.find_by_slug(params[:id]).sandbox?
  end

  def verify_app_owner
    unless current_user && App.find_by_slug(params[:id]).has_owner?(current_user)
      redirect_to apps_path, :alert => "You are not allowed to edit this app."
    end
  end

  def get_current_user_apps
    @current_user_apps = current_user ? current_user.installed_apps : []
  end

  # GET /apps
  def index
    @apps = App.authentic_apps
  end
  
  # GET /apps/1
  def show
    @app = App.find_by_slug(params[:id])
  end
  
  def new
    @app = App.new
  end

  def edit
    @app = App.find_by_slug(params[:id])
  end

  def update
    @app = App.find_by_slug(params[:id])
    respond_to do |format|
      if @app.update_attributes(params[:app])
        format.html { redirect_to @app, :alert => "App was successfully updated."}
      else
        render :action => 'new' 
      end
    end
  end

  def create
    @app = App.new(params[:app], ){|app| app.user_id = current_user.id}
    @app.update_attributes(status: 'sandbox')
    respond_to do |format|
      if @app.save
        format.html { redirect_to @app, :alert => "App was successfully created. Secret: #{@app.oauth2_client.client_secret} Client id: #{@app.oauth2_client.client_id}"}
      else
        render :action => 'new' 
      end
    end
  end

  def install
    app = App.find_by_slug(params[:id])
    # An app's client_id is needed to create an authorization from this site.
    oauth2_client = OAuth2::Model::Client.find_by_oauth2_client_owner_id(app.id)
    auth = OAuth2::Provider::Authorization.new(current_user, client_id: oauth2_client, redirect_uri: "http://localhost:3005/auth/mygov/callback", state: "asdf")
  end

  def uninstall
    app = App.find_by_slug(params[:id])
    current_user.oauth2_authorizations.find{|oa| oa.client.owner == app}.destroy
    respond_to do |format|
      format.html { redirect_to app_path(app) }# index.html.erb
    end
  end  
end