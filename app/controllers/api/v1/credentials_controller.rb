class Api::V1::CredentialsController < Api::ApiController
  before_filter :oauthorize_scope

  def verify
    access_token_hash = OAuth2.hashify(params[:access_token])
    oauth_scope = OauthScope.find_by_scope_name(params[:scope])
    unless oauth_scope
      render :json => {:message => 'The scope you are requesting to validate is not a recognized MyUSA scope; you may need to register your scope with MyUSA.'}, :status => 400
    else
      authorization = OAuth2::Model::Authorization.find_by_access_token_hash(access_token_hash)
      if authorization
        scope_list = authorization && authorization.scope
        if scope_in_scope_list?(oauth_scope, scope_list)
          render :json => {}, :status => 200
        else
          render :json => {:message => "The requesting application does not have access to #{oauth_scope.name.downcase} for that user."}, :status => 403
        end
      else
        render :json => {:message => 'The access token you attempting to verify is not a valid access token.'}, :status => 400
      end
    end
  end
  
  protected
  
  def no_scope_message
    "You do not have permission to verify other application's credentials."
  end
  
  def oauthorize_scope
    validate_oauth(OauthScope.find_all_by_scope_name('verify_credentials'))
  end
end