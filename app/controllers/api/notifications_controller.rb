class Api::NotificationsController < Api::ApiController
  
  def create
    unless @token.valid?
      render :json => {:status => 'Error', :message => "You do not have access to send notifications to that user."}, :status => 403
    else
      @user = @token.owner
      notification = @user.notifications.build(params[:notification])
      notification.received_at = Time.now
      notification.user_id = @user.id
      notification.o_auth2_model_client_id = @token.client.id
      if notification.save
        render :json => {:status => 'OK', :message => 'Your notification was successfully created.'}
      else
        render :json => {:status => 'Error', :message => notification.errors}, :status => 400
      end
    end
  end
end
