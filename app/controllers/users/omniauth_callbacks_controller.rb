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
      @user.update_attributes(:is_approved => true) if session[:user_return_to] =~ /^\/app.*$/
      if !@user.is_approved? and @user.just_created
        redirect_to thank_you_path
      else
        sign_in_and_redirect @user, :event => :authentication
      end
    else
      session["devise.#{provider_name}_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end