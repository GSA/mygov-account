class Users::SessionsController < Devise::SessionsController
  auto_session_timeout_actions
  
  def active
   render_session_status
  end

  def timeout
    flash[:notice] = "Your session has timed out."
    redirect_to "/sign_in?timeout=true"
  end  
end
