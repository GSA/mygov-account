class HomeController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :privacy_policy, :terms_of_service]
  before_filter :assign_user, :except => [:index, :privacy_policy, :terms_of_service]
  
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
    @us_holiday = UsHoliday.find_by_observed_on(@today)
    @events = UsHistoricalEvent.find_all_by_month_and_day(@today.month, @today.day)
    if @user.zip
      daily_uv_response = EpaUvIndex::Client.daily_for(:zip => @user.zip) rescue nil
      @uv_index = daily_uv_response.first["UV_INDEX"] if daily_uv_response and daily_uv_response.first
    end
    @local_info = @user.local_info
  end
  
  def privacy_policy
  end
  
  def terms_of_service
  end
  
  def your_government
    @local_info = @user.local_info
  end
end