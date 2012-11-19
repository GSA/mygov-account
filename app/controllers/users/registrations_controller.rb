class Users::RegistrationsController < Devise::RegistrationsController
  
  def thank_you
  end
  
  def after_inactive_sign_up_path_for(resource)
    thank_you_path
  end
end