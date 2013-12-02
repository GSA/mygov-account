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

  def update
    redirect_to edit_user_registration_path
  end

  # def edit
  #   raise 'inside edit'
  #   redirect_to edit_user_registration_path unless super
  # end

  def thank_you
  end

  def after_inactive_sign_up_path_for(resource)
    thank_you_path
  end

  def after_update_path_for(resource)
    edit_user_registration_path
  end
end
