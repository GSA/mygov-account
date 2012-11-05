class HomeController < ApplicationController
  before_filter :authenticate_user!, :only => [:dashboard]
  before_filter :assign_user, :only => [:dashboard]
  
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
  end
  
  def render_page
    render params[:page]
  end
  
end
