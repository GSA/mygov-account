class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :validate_accepted_tos, :only => [:create]
  
  def thank_you
  end
  
  def after_inactive_sign_up_path_for(resource)
    thank_you_path
  end
  
  private
  
  def validate_accepted_tos
    unless params[:accept] == "1"
      @user = User.new(params[:user])
      flash[:alert] = "Please read and accept the MyGov Terms of Service and Privacy Policy."
      render :new
    end
  end
end