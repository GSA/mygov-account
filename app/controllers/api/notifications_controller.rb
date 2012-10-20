class Api::NotificationsController < Api::ApiController
  
  def create
    unless @token.valid?
      render :json => {:status => 'Error', :message => "You do not have access to send messages to that user."}, :status => 403
    else
      @user = @token.owner
      message = @user.messages.build(params[:message])
      message.received_at = Time.now
      message.user_id = @user.id
      message.o_auth2_model_client_id = @token.client.id
      if message.save
        render :json => {:status => 'OK', :message => 'Your message was successfully created.'}
      else
        render :json => {:status => 'Error', :message => message.errors}, :status => 400
      end
    end
  end
end
