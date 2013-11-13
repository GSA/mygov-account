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

  private

  def callback(provider_name)
    @user = User.find_for_open_id(request.env["omniauth.auth"], current_user)
    if @user.persisted? && @user.errors.blank?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => provider_name.capitalize
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.#{provider_name}_data"] = request.env["omniauth.auth"].except("extra")
      if @user.errors[:base].include?("I'm sorry, your account hasn't been approved yet.")
        flash[:alert] = "I'm sorry, your account hasn't been approved yet."
      elsif @user.errors[:email].include?('has already been taken')
        flash[:alert] = "We already have an account with that email. Make sure login with the service you used to create the account."
      elsif @user.errors[:authentications].include?('is invalid')
        flash[:alert] = "This external account is already linked to another MyUSA account."
      else
        flash[:alert] = "An unexpected error has occured; please try to sign up again."
      end
      omniauth_params = env["omniauth.params"]
      redirect_to (omniauth_params && omniauth_params["error_return_to"]) || new_user_registration_url
    end
  end
end