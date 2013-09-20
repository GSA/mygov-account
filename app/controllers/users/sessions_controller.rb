class Users::SessionsController < Devise::SessionsController

  ## @@NOTE: overriding the Devise create method to add the custom
  ## render which breaks the redirect into two pieces

  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    render :json => { :user_key_storage_name => @user.key_storage_name, :after_signin_path => after_sign_in_path_for(resource) }.to_json() 

    # previously, following resource line was returned
    # respond_with resource, :location => after_sign_in_path_for(resource)
  end
  
  def more_sign_in_options
  end
end
