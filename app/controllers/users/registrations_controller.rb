class Users::RegistrationsController < Devise::RegistrationsController
  skip_before_filter :set_no_keep_alive
  prepend_before_filter :set_no_keep_alive
  helper_method :recaptcha_needed?

  def create
    if session[:omniauth] == nil
      if verify_recaptcha_if_needed
        if !!session[:request_env_omniauth]
          @user = User.find_for_open_id(session[:request_env_omniauth], current_user, params[:user][:terms_of_service])
          sign_in_and_redirect @user, :event => :authentication
          return
        end

        super
        session[:omniauth] = nil unless @user.new_record?
        session[:account_created] = true if @user.valid?
      else
        build_resource( sign_up_params )
        resource.valid?
        clean_up_passwords(resource)
        resource.errors.add(:base, "There was an error with the code below. Please re-enter!")
        render :new
        session[:omniauth] = nil
        return false
      end
    else
      super
      session[:omniauth] = nil unless @user.new_record? 
    end
  end

  def thank_you
  end
  
  protected
  
  def after_inactive_sign_up_path_for(resource)
    thank_you_path
  end
  
  def after_update_path_for(resource)
    edit_user_registration_path
  end
  
  # Build a devise resource passing in the session. Useful to move
  # temporary session data to the newly created user.
  def build_resource(hash=nil)
    super(hash)
    self.resource.auto_approve = true if self.resource && session[:auto_approve_account] == true
  end
  
  def recaptcha_needed?
    !!session[:account_created]
  end
  
  def verify_recaptcha_if_needed
    recaptcha_needed? ? verify_recaptcha : true
  end
end
