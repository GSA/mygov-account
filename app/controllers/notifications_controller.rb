class NotificationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_user
  before_filter :find_notifications
  
  def index
    @notifications = @user_notifications.paginate(:page => params[:page], :per_page => 10).order('received_at DESC')
  end
  
  def show
    @notification = @user_notifications.find(params[:id])
  end

  def destroy
    @notification = @user_notifications.find(params[:id])
    unless @notification
      redirect_to notifications_path(:page => params[:page]), notice: "Notification could not be found."
      return
    end
    @notification.destroy
    flash[:notice] = "The notification has been deleted."
    redirect_to notifications_path(:page => params[:page])
  end
  
  protected
  
  def find_notifications
    @user_notifications = @user.notifications.not_deleted
  end
end
