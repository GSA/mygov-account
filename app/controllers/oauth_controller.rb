class OauthController < ApplicationController
  
  def authorize
    @oauth2 = OAuth2::Provider.parse(current_user, request)
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
  
  def test 
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
    @outh2_client =  OAuth2::Model::Client.find_by_client_id(params[:client_id])
    @app = App.find(@outh2_client.oauth2_client_owner_id)
    if @app.sandbox?
      pass = @app.user == current_user ? true : false
    else
      pass = true
    end
    return pass
  end

end
