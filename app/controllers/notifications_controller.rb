class NotificationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_user
  
  def index
    @notifications = @user.notifications.paginate(:page => params[:page], :per_page => 10).order('received_at DESC')
  end
  
  def show
    @notification = @user.notifications.find_by_id(params[:id])
  end

  def destroy
    @notification = @user.notifications.find_by_id(params[:id])
    @notification.destroy
    flash[:notice] = "The notification has been deleted."
    redirect_to notifications_path(:page => params[:page])
  end
end
