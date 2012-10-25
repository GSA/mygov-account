class Users::ConfirmationsController < Devise::ConfirmationsController
  
  def after_confirmation_path_for(resource_name, resource)
    welcome_path
  end
end