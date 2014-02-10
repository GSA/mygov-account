class Users::PasswordsController < Devise::PasswordsController
  skip_before_filter :set_no_keep_alive
  prepend_before_filter :set_no_keep_alive
  before_filter :validate_email_devise, only: :create

  def new
    flash[:notice] = nil
    super
  end

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    set_flash_message(:notice, 'ambiguous_email')
    self.resource.errors.clear
    render :new  
  end
  
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with resource, :location => after_resetting_password_path_for(resource)
      resource.send_reset_password_confirmation
    else
      respond_with resource
    end
  end
end