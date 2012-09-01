class ApplicationController < ActionController::Base
  protect_from_forgery
  
  protected
  
  def assign_user
    @user = current_user
  end
  
  def oauthorize
    @user = User.find_by_id(params[:id])
    @token = OAuth2::Provider.access_token(@user, [], request)
  end
end
