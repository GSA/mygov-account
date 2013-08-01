class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :verify_authenticity_token
  
  def google
    callback('google')
  end
  
  def paypal
    callback('paypal')
  end
  
  def verisign
    callback('verisign')
  end
  
  def ficamidp
    callback('ficamidp')
  end
  
  def testid
    callback('testid')
  end
  
  def maxgov
    auth = request.env["omniauth.auth"]
    if current_user
      authentication = current_user.authentications.find_or_create_by_provider_and_uid("max.gov", auth.uid)
      if authentication.errors.empty?
        redirect_to authentications_path
      else
        redirect_to new_authentication_path
      end
    else
      authentication = Authentication.find_by_provider_and_uid("max.gov", auth.uid)
      if authentication and authentication.user
        sign_in_and_redirect authentication.user, :event => :authentication
      else
        flash[:alert] = "I'm sorry, we don't have an account associated with your MAX.gov account.  Please login and visit Settings -> Authentication providers to associate your MyUSA account with your MAX.gov account."
        redirect_to sign_in_path
      end
    end
  end
  
  private
  
  def callback(provider_name)
    @user = User.find_for_open_id(request.env["omniauth.auth"], current_user)
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => provider_name.capitalize
      if @user == current_user or !@user.id_changed?
        sign_in_and_redirect @user, :event => :authentication
      else # send user to dashboard if newly registered instead of devise redirect
        sign_in @user
        redirect_to :dashboard
      end
    else
      session["devise.#{provider_name}_data"] = request.env["omniauth.auth"].except("extra")
      if @user.errors[:base].include?("I'm sorry, your account hasn't been approved yet.")
        flash[:alert] = "I'm sorry, your account hasn't been approved yet."
      elsif @user.errors[:email].include?('has already been taken')
        flash[:alert] = "We already have an account with that email. Make sure login with the service you used to create the account."
      else
        flash[:alert] = "An unexpected error has occured; please try to sign up again."
      end
      redirect_to new_user_registration_url
    end
  end
end