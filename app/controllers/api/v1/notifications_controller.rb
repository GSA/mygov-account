class Api::V1::NotificationsController < Api::ApiController
  before_filter :oauthorize_scope

  def create
    notification = Notification.new
    notification.assign_attributes({
        :subject => params[:notification][:subject],
        :body => params[:notification][:body],
        :user_id => @user.id,
        :app_id => @app.id,
        :received_at => Time.now,
        :notification_type => params[:notification][:notification_type]
      }, :as => :admin)
    if notification.save
      render :json => notification, :status => 200
    else
      render :json => {:message => notification.errors}, :status => 400
    end
  end

  protected

  def no_scope_message
    "You do not have permission to send notifications to that user."
  end

  def oauthorize_scope
    validate_oauth(OauthScope.find_all_by_scope_name('notifications'))
  end
end
