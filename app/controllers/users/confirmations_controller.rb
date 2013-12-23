class Users::ConfirmationsController < Devise::ConfirmationsController
  before_filter :validate_email_devise, only: :create
  
  def create
    set_flash_message(:notice, 'ambiguous_email')
    super
  end
  
  protected
  
  def after_confirmation_path_for(resource_name, resource)
    dashboard_path
  end
end