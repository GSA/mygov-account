class ApplicationController < ActionController::Base
  prepend_before_filter :set_no_keep_alive
  ensure_security_headers
  before_timedout_action
  skip_before_filter :set_csp_header
  protect_from_forgery
  after_filter :set_response_headers, :cors_set_access_control_headers
  before_filter :set_session_will_expire, :cors_preflight_check
  helper_method :recaptcha_needed?

  auto_session_timeout User.timeout_in.seconds

  def xss_options_request
    render :text => ""
  end

  protected
  
  def valid_url?(uri)
    !!((uri =~ URI::regexp(["http", "https"])))
  rescue URI::InvalidURIError
    false
  end
  
  def member_subdomain?(url_list, url)
    url_list.any? do |list_url|
      list_host = URI.parse(list_url).host
      url_host = URI.parse(url).host
      list_host == url_host || url_host.ends_with?(".#{list_host}")
    end
  end
  
  def after_sign_out_path_for(resource_or_scope)
    url = params[:continue]
    if !url.blank? && valid_url?(url) && current_user && member_subdomain?(current_user.authorized_apps.map(&:url), url)
      return url
    end
    sign_in_path
  end

  def after_sign_in_path_for(resource)
    after_auth_return_to = session.delete(:after_auth_return_to)
    stored_location = stored_location_for(resource)
    after_auth_return_to || stored_location ||
      if resource.is_a?(User)
        dashboard_url
      else
        super(resource)
      end
  end

  def recaptcha_needed?
    !!session[:account_created]
  end

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

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*' #TODO: Specify permitted domains
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS, DELETE'
    headers['Access-Control-Max-Age'] = "1728000"
    headers["Access-Control-Allow-Headers"] = "Content-Type, X-Requested-With, Authorization"
  end

  # If this is a preflight OPTIONS request, then short-circuit the
  # request, return only the necessary headers and return an empty
  # text/plain.
  def cors_preflight_check
    if request.method == :options
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS, DELETE'
      headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, Authorization'
    end
  end
end