class BetaSignupsController < ApplicationController
  layout 'signup'
  
  def create
    beta_signup = BetaSignup.create(params[:beta_signup].merge(:ip_address => request.remote_ip, :referrer => request.referer))
    @result = ( beta_signup.id.nil? ) ? false : true

    respond_to do |format|
        format.html
        format.json { render :json => { result: @result }  }
    end
  end
end
