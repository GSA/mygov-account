class HomeController < ApplicationController
  before_filter :authenticate_user!, :only => [:dashboard]
  before_filter :assign_user, :only => [:dashboard]
  
  def index
    redirect_to :dashboard if current_user
  end
  
  def dashboard
    @today = Date.current
    @uncompleted_tasks = @user.tasks.uncompleted.order('created_at DESC')
    @us_holiday = UsHoliday.find_by_observed_on(@today)
    @events = UsHistoricalEvent.find_all_by_month_and_day(@today.month, @today.day)
  end

  def thank_you
  end
end
