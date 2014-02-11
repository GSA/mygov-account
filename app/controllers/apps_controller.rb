require 'uri'

class AppsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show, :leaving]
  before_filter :assign_user
  before_filter :assign_app, :only => [:show, :edit, :destroy, :update, :uninstall, :leaving]
  before_filter :assign_user_installed_apps, :only => [:index, :show]
  before_filter :assign_oauth_scopes, :only => [:new, :create, :edit, :destroy, :update]
  before_filter :verify_app_owner, :only =>  [:edit, :update, :destroy]
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
      @app.app_oauth_scopes.each { |scope| scope.destroy }

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
  
  def leaving
    # Make sure that "About to leave this site" warning only displays when appropriate.
    @put_leaving_usa = App.compare_domains(request.domain, @app.url)
  end

  def destroy
    unless @app
      redirect_to apps_path(:page => params[:page]), notice: "App could not be found."
      return
    end
    
    unless @app.can_delete?
      redirect_to app_path(@app), notice: "App cannot be deleted."
      return
    end
    
    @app.destroy
    flash[:notice] = "The app has been deleted."
    redirect_to apps_path(:page => params[:page])
  end
  
  private
  
  def assign_app
    @app = App.find_by_slug(params[:id])
  end

  def assign_user_installed_apps
    @user_installed_apps = @user ? @user.installed_apps : []
  end
  
  def assign_oauth_scopes
    @scope_groups = OauthScope.top_level_scopes.where(:scope_type => 'user')
    @grouped_scopes = {}
    @scope_groups.each do |scope_group|
      scopes = OauthScope.where("scope_name LIKE :group_name", :group_name => "#{scope_group.scope_name}.%")
      @grouped_scopes[scope_group.scope_name.to_sym] = scopes unless scopes.empty?
    end
  end
  
  def verify_public_or_is_owner
    return true if @app.is_public or (@app.sandbox? and @app.user == @user)
    redirect_to apps_path
  end

  def verify_app_owner
    redirect_to apps_path, :alert => "You are not allowed to edit this app." unless @app.user == @user
  end
end
