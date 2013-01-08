class Api::ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :oauthorize
  
  protected
  
  def oauthorize
    @token = OAuth2::Provider.access_token(@user, [], request)
    if @token.valid?
      @app = @token.authorization.client.owner
      @user = @token.owner
    end
  end
  
  def no_scope_message
    "You do not have access to read that user's profile."
  end
  
  def validate_oauth(oauth_scope = nil)
    unless @token.valid?
      render :json => {:status => "Error", :message => self.no_scope_message}, :status => 403
      return false
    end
    
    return true unless oauth_scope
    
    auth = @token.authorization
    scope_list = auth && auth.scope
    unless (scope_list || "").split(" ").member?(oauth_scope.scope_name)
      render :json => {:status => 'Error', :message => "You do not have access to #{oauth_scope.name.downcase} for that user."}, :status => 403
      return false
    end
  end
end