class Users::RegistrationsController < Devise::RegistrationsController

  def create
    if session[:omniauth] == nil
      if verify_recaptcha
        super
        session[:omniauth] = nil unless @user.new_record? 
      else
        build_resource( sign_up_params )
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
end
