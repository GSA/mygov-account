class Users::SessionsController < Devise::SessionsController
  auto_session_timeout_actions
  def active
   render_session_status
  end

  def timeout
    render_session_timeout
  end
end
