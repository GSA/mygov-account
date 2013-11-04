class ApplicationController < ActionController::Base
  ensure_security_headers
  skip_before_filter :set_csp_header
  protect_from_forgery
  prepend_before_filter :set_no_keep_alive
  before_filter :set_segment
  before_filter :set_session_will_expire
  after_filter :set_response_headers

  def after_sign_out_path_for(resource_or_scope)
    sign_in_path
  end

  def after_sign_in_path_for(resource_or_scope)
    session[:after_auth_return_to] || super(resource_or_scope)
  end

  protected

  def set_no_keep_alive
    request.env["devise.skip_trackable"] = true unless params[:no_keep_alive].blank?
  end

  def set_session_will_expire
    # Devise.setup { |config| config.timeout_in = 20 }                # For testing
    # Rails.application.config.session_timeout_warning_seconds = 10   # For testing
    @warning_seconds    = Rails.application.config.session_timeout_warning_seconds.seconds # default number of seconds before timeout to display warning message
    @wait_until_refresh = User.timeout_in - @warning_seconds # actual number of seconds to wait for refresh to display warning message
    if current_user && params[:no_keep_alive].present?
      last_request                = warden.session(:user)['last_request_at'] # date/time of last activity
      seconds_since_last_request  = [(Time.now.to_i - last_request.to_i).seconds, 0].max
      seconds_left_in_session     = [User.timeout_in - seconds_since_last_request, 0].max # recalculates number of seconds left in current session
      @session_to_expire_soon     = true if seconds_left_in_session > 0 && (last_request + current_user.timeout_in - @warning_seconds) <= Time.now
      if @session_to_expire_soon
        @wait_until_refresh       = seconds_left_in_session + 1 # recalculates number of seconds left in current session
      else
        @wait_until_refresh       = [User.timeout_in + 1 - seconds_since_last_request - @warning_seconds, 1].max # recalculates number of seconds left until warning
      end
    end
  end

  def assign_user
    @user = current_user
  end

  def set_segment
    if !session[:segment]
      session[:segment] = rand(2) == 0 ? "A" : "B"
    end
    @segment = session[:segment]
  end

  def set_response_headers
    headers['X-XRDS-Location'] = url_for(:action => 'xrds', :controller => 'home', :protocol => 'https', :only_path => false, :format => :xml)
  end

  def forgot_password_link(text)
    view_context.link_to(text, new_user_password_path)
  end

  def validate_email_devise
    email = resource_params[:email]
    if email.blank?
      set_flash_message(:notice, 'email_required')
      self.resource = resource_class.new
      render :new
      return false
    elsif !ValidatesEmailFormatOf::validate_email_format(email).nil?
      set_flash_message(:notice, 'email_invalid')
      self.resource = resource_class.new
      render :new
      return false
    end
    true
  end
end
