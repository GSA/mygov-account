class Users::ConfirmationsController < Devise::ConfirmationsController
  skip_before_filter :set_no_keep_alive
  prepend_before_filter :set_no_keep_alive
  before_filter :validate_email_devise, only: :create
  
  def create
    self.resource = resource_class.send_confirmation_instructions(resource_params)
    set_flash_message(:alert, 'ambiguous_email')
    redirect_to after_resending_confirmation_instructions_path_for(resource_name)
  end
end