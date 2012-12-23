class BetaSignupsController < ApplicationController
  layout 'signup'
  
  def create
    beta_signup = BetaSignup.create(params[:beta_signup].merge(:ip_address => request.remote_ip, :referrer => request.referer))
  end
end
