class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_segment
  
  def after_sign_out_path_for(resource_or_scope)
    sign_in_path
  end
  
  protected
  
  def assign_user
    @user = current_user
  end
  
  def set_segment
    if !session[:segment]
      session[:segment] = rand(2) == 0 ? "A" : "B"
    end
    @segment = session[:segment]
  end
end
