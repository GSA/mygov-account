class Users::UnlocksController < Devise::UnlocksController
  prepend_before_filter :require_no_authentication
  before_filter :validate_email_devise, only: :create

  def create
    self.resource = resource_class.send_unlock_instructions(resource_params)
    set_flash_message(:alert, 'ambiguous_email')
    redirect_to after_sending_unlock_instructions_path_for(resource)
  end
end