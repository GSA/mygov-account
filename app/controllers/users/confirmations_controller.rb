class Users::ConfirmationsController < Devise::ConfirmationsController
  
  # POST /resource/confirmation
  def create
    self.resource = resource_class.send_confirmation_instructions(resource_params)

    set_flash_message(:notice, 'ambiguous_email')
    self.resource.errors.clear
    render :new
  end
  
  protected
  
  def after_confirmation_path_for(resource_name, resource)
    dashboard_path
  end
end