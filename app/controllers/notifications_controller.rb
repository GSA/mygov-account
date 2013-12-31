class NotificationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_user
  before_filter :find_notifications
  
  def index
    @page = [[(params[:page] || "1").to_i, (@user_notifications.count.to_f / 10).ceil].min,1].max
    @notifications = @user_notifications.paginate(:page => @page, :per_page => 10).newest_first
  end
  
  def show
    @notification = @user_notifications.find(params[:id])
    @notification.view!
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
