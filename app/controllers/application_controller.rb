class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_segment
  
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
