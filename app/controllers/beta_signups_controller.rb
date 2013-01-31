class BetaSignupsController < ApplicationController
  layout 'signup'
  
  def create
    @beta_signup = BetaSignup.create(params[:beta_signup].merge(:ip_address => request.remote_ip, :referrer => request.referer))
    unless @beta_signup.errors.blank?
      flash.now[:alert] = t('beta_signup_error')
      render '/home/index', :layout => 'signup'
    end
  end
end
