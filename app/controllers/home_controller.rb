class HomeController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :discovery, :developer, :privacy_policy, :terms_of_service, :about]
  before_filter :assign_user, :except => [:index, :privacy_policy, :developer, :terms_of_service]
  
  def index
    if current_user
      redirect_to :dashboard 
    else
      @beta_signup = BetaSignup.new
      render :layout => 'signup'
    end
  end
  
  def dashboard
    @today = Date.current
    @uncompleted_tasks = @user.tasks.uncompleted.order('created_at DESC')
    @local_info = @user.local_info
  end
  
  def developer
  end

  def discovery
  end
  
  def privacy_policy
  end
  
  def terms_of_service
  end
  
  def about
  end
  
  def pra
  end
  
  def your_government
    @local_info = @user.local_info
  end
end