class ApplicationController < ActionController::Base
  protect_from_forgery
  prepend_before_filter :set_no_keep_alive
  before_filter :set_segment
  before_filter :set_timeout_warning_durations
  before_filter :set_session_will_expire
  
  def after_sign_out_path_for(resource_or_scope)
    sign_in_path
  end
  
  protected
    
  def set_timeout_warning_durations
    @warning_seconds = Rails.application.config.session_timeout_warning_seconds.seconds
    @wait_until_refresh = User.timeout_in - @warning_seconds 
  end
  
  def set_no_keep_alive
    request.env["devise.skip_trackable"] = true if !params[:no_keep_alive].blank?
  end

  def set_session_will_expire    
    if current_user && !params[:no_keep_alive].blank?
      last_request               = warden.session(:user)['last_request_at'] 
      seconds_since_last_request = Time.now.to_i - last_request.to_i
      @session_will_expire = true if (warden.session(:user)['last_request_at'] + current_user.timeout_in) <= @warning_seconds.seconds.from_now
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
end
