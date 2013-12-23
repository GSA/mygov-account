class Users::UnlocksController < Devise::UnlocksController
  prepend_before_filter :require_no_authentication
  before_filter :validate_email_devise, only: :create

  def create
    set_flash_message(:notice, 'ambiguous_email')
    super
  end
end