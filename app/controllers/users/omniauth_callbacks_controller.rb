class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :verify_authenticity_token, :only => [:google, :paypal, :verisign]
  
  def google
    callback('Google')
  end
  
  def paypal
    callback('Paypal')
  end
  
  def verisign
    callback('Verisign')
  end
  
  private
  
  def callback(kind)
    @user = User.find_for_open_id(request.env["omniauth.auth"], current_user)
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => kind
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.paypal_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end