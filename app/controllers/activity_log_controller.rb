class ActivityLogController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_user

  def list
    @activity_logs = @user.app_activity_logs.find(:all)
  end

  def show
  end
end
