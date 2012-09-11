class HomeController < ApplicationController
  before_filter :authenticate_user!, :only => [:dashboard]
  before_filter :assign_user, :only => [:dashboard]
  
  def index
    redirect_to :dashboard if current_user
  end
  
  def dashboard
  end  
end
