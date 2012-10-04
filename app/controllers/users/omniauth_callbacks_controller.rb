class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :verify_authenticity_token, :only => [:google, :paypal, :verisign]
  
  def google
    callback('google')
  end
  
  def paypal
    callback('paypal')
  end
  
  def verisign
    callback('verisign')
  end
  
  private
  
  def callback(provider_name)
    @user = User.find_for_open_id(request.env["omniauth.auth"], current_user)
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => provider_name.capitalize
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.#{provider_name}_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end