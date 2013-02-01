class BetaSignupsController < ApplicationController
  layout 'signup'
  
  def create
    @beta_signup = BetaSignup.create(params[:beta_signup].merge(:ip_address => request.remote_ip, :referrer => request.referer))
    unless @beta_signup.errors.blank?
      # only going to display the first error, since there is only one field,
      #  and the error display field is small
      flash.now[:alert] = @beta_signup.errors.full_messages.first
      render '/home/index', :layout => 'signup'
    end
  end
end
