class BetaSignupsController < ApplicationController
  
  def create
    BetaSignup.create(params[:beta_signup].merge(:ip_address => request.remote_ip, :referrer => request.referer))
  end
end
