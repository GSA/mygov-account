class OauthController < ApplicationController
  before_filter :set_client_app, :only => [:authorize, :allow]
  before_filter :set_client_credentials_handler, :only => [:authorize]
  
  after_filter ({ :only => :authorize }) do |controller|
    controller.log_app_authorization(controller)
  end

  def authorize
    @oauth2 = OAuth2::Provider.parse(current_user, request.env)
    if @oauth2.redirect?
      redirect_to @oauth2.redirect_uri, :status => @oauth2.response_status
    else
      headers.merge!(@oauth2.response_headers)
      if @oauth2.response_body
        render :text => @oauth2.response_body, :status => @oauth2.response_status
      else
        session[:user_return_to] = request.original_fullpath if authenticate_user!
      end
    end
  end
  
  def allow
    @auth = OAuth2::Provider::Authorization.new(current_user, params)
    if params[:allow] == '1' and params[:commit] == 'Allow' && pass_sandbox_check(params)
      @auth.grant_access!
    else
      @auth.deny_access!
    end
    redirect_to @auth.redirect_uri, :status => @auth.response_status
  end

  def pass_sandbox_check params
    pass = false
    if @app.sandbox?
      pass = @app.user == current_user ? true : false
    else
      pass = true
    end
    return pass
  end

  def unknown_app
  end

  protected

  def set_client_app
    begin
      @oauth2_client =  OAuth2::Model::Client.find_by_client_id(params[:client_id])
      @app = App.find(@oauth2_client.oauth2_client_owner_id) if params[:grant_type] != 'client_credentials'
    rescue NoMethodError
      redirect_to unknown_app_path
    end
  end
  
  def set_client_credentials_handler
    OAuth2::Provider.handle_client_credentials do |client, owner, scopes|
      owner.user.grant_access!(client, :scopes => ['verify_credentials'])
    end
  end

  def log_app_authorization(controller)
    AppActivityLog.create!(:app => @app, :controller => controller.controller_name, :action => controller.action_name, :user => current_user)
  end
end
