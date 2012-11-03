class BetaSignupsController < ApplicationController
  layout 'signup'
  
  def create
    beta_signup = BetaSignup.create(params[:beta_signup].merge(:ip_address => request.remote_ip, :referrer => request.referer))
    if ( beta_signup.errors.messages[:email].nil? )
      @result = "success"
    else 
      @result = beta_signup.errors.messages[:email].first
    end
    respond_to do |format|
        format.html
        format.json { render :json => { result: @result }  }
    end
  end
end
