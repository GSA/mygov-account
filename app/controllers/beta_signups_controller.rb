class BetaSignupsController < ApplicationController
  layout 'signup'
  
  def create
    beta_signup = BetaSignup.create(params[:beta_signup].merge(:ip_address => request.remote_ip, :referrer => request.referer))
    redirect_to root_path, :alert => t('beta_signup_error') unless beta_signup.errors.blank?
  end
end
