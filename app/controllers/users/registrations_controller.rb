class Users::RegistrationsController < Devise::RegistrationsController
  skip_before_filter :set_no_keep_alive
  prepend_before_filter :set_no_keep_alive
  helper_method :recaptcha_needed?

  def create
    @using_oauth = !!flash[:original_fullpath]
    if session[:omniauth] == nil
      flash.keep(:original_fullpath) if @using_oauth
      if verify_recaptcha_if_needed
        if @using_oauth
          auth_hash = Authentication.auth_hash_from_uri(flash[:original_fullpath]) 
          @user = User.find_for_open_id(auth_hash, current_user, params[:user])
          if @user.valid?
            sign_in_and_redirect @user, :event => :authentication if @user.valid?
          else
            @user = User.find_for_open_id(auth_hash, current_user, params[:user])
            @user.attributes = {"password" => User.default_password}
            render :new
          end
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
