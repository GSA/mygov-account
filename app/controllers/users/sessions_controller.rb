class Users::SessionsController < Devise::SessionsController
  
  def new
    redirect_to session[:user_return_to] || root_path
  end
  
  def destroy
    reset_session
    redirect_to root_path
  end
end