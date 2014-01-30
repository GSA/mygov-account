class Api::ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :oauthorize
  after_filter {|controller| log_activity(controller)}

  protected

  def oauthorize
    @token = OAuth2::Provider.access_token(nil, [], request)
    if @token.valid?
      @app = @token.authorization.client.owner
      @user = @token.owner
    end
  end
  
  def validate_oauth(oauth_scopes)
    unless @token.valid?
      render :json => {:message => "Invalid token"}, :status => @token.response_status
      return false
    end

    auth = @token.authorization
    scope_list = auth && auth.scope
    
    oauth_scopes.each do |oauth_scope|
      return true if scope_in_scope_list?(oauth_scope, scope_list)
    end
    
    render :json => {:message => no_scope_message}, :status => 403
    return false
  end
  
  def scope_in_scope_list?(oauth_scope, scope_list)
    return true if (scope_list || "").split(" ").member?(oauth_scope.scope_name)
    return false
  end

  def log_activity(controller)
    AppActivityLog.create!(:app => @app, :controller => controller.controller_name, :action => controller.action_name, :user => @user)
  end
end
