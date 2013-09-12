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
  
  protected
      
  def set_no_keep_alive
    request.env["devise.skip_trackable"] = true if !params[:no_keep_alive].blank?
  end

  def set_session_will_expire
    @warning_seconds = Rails.application.config.session_timeout_warning_seconds.seconds
    @wait_until_refresh = User.timeout_in - @warning_seconds 
    if current_user && !params[:no_keep_alive].blank?
      last_request                = warden.session(:user)['last_request_at'].to_i
      seconds_since_last_request  = [(Time.now.to_i - last_request).seconds, 0].max
      @wait_until_refresh         = [User.timeout_in - seconds_since_last_request, 0].max
      @session_will_expire        = true if @wait_until_refresh > 0 && (warden.session(:user)['last_request_at'] + current_user.timeout_in) <= @warning_seconds.from_now
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
end
