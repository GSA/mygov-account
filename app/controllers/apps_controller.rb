class AppsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :assign_user
  before_filter :assign_app, :only => [:show, :edit, :update, :uninstall]
  before_filter :assign_user_installed_apps, :only => [:index, :show]
  before_filter :assign_oauth_scopes, :only => [:new, :create, :edit, :update]
  before_filter :verify_app_owner,  :only =>  [:edit, :update]
  before_filter :verify_public_or_is_owner, :only => [:show]

  def index
    @apps = App.authentic_apps
    @sandbox_apps = @user ? @user.sandbox_apps : []
  end
  
  def new
    @app = App.new
  end

  def create
    @app = App.new(params[:app])
    if @app.app_oauth_scopes.empty?
      @app.valid?      
      @app.errors.add(:base, 'Please select at least one scope.')
      render :action => 'new'
    else
      @app.user = @user
      if @app.save
        session[:app] = {client_secret: @app.oauth2_client.client_secret}
        redirect_to @app
      else
        render :action => 'new' 
      end
    end
  end

  def show
    if session[:app]
      @client_secret = session[:app][:client_secret]
      session[:app] = nil
    end
  end
  
  def edit
  end

  def update
    respond_to do |format|
      if @app.update_attributes(params[:app])
        format.html { redirect_to @app, :alert => "App was successfully updated."}
      else
        render :action => 'new' 
      end
    end
  end

  def uninstall
    @user.oauth2_authorizations.find{|oauth_authorization| oauth_authorization.client.owner == @app}.destroy
    redirect_to app_path(@app)
  end
  
  private
  
  def assign_app
    @app = App.find_by_slug(params[:id])
  end

  def assign_user_installed_apps
    @user_installed_apps = @user ? @user.installed_apps : []
  end
  
  def assign_oauth_scopes
    @oauth_scopes = OauthScope.all
  end
  
  def verify_public_or_is_owner
    return true if @app.is_public or (@app.sandbox? and @app.has_owner?(@user))
    redirect_to apps_path
  end

  def verify_app_owner
    redirect_to apps_path, :alert => "You are not allowed to edit this app." unless @app.has_owner?(@user)
  end
end