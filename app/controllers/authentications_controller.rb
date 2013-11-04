class AuthenticationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_user

  def index
    session[:after_auth_return_to] = authentications_path
    @authentications = @user.authentications
  end
  
  def new
    
  end
  
  def show
    @authentication = @user.authentications.find(params[:id])
  end
  
  def destroy
    @authentication = @user.authentications.find(params[:id])
    @authentication.destroy
    redirect_to authentications_path
  end
end
