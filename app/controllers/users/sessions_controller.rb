class Users::SessionsController < Devise::SessionsController
  auto_session_timeout_actions
  
  def active
   render_session_status
  end

  def timeout
    flash[:notice] = I18n.t('custom_session_timeout')
    redirect_to sign_in_url(timeout: "true")
  end  
end
