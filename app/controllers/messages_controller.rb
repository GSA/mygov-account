class MessagesController < ApplicationController
  before_filter :authenticate_user!, :except => [:create]
  before_filter :assign_user, :except => [:create]
  
  def index
    @messages = @user.messages.paginate(:page => params[:page], :per_page => 10).order('received_at DESC')
  end
  
  def create
    @user = User.find_by_id(params[:id])
    @token = OAuth2::Provider.access_token(@user, [], request)
    unless @token.valid?
      render :json => {:status => 'Error', :message => "You do not have access to send messages to that user."}, :status => 403
    else
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

  def show
    @message = @user.messages.find_by_id(params[:id])
  end

  def destroy
    @message = @user.messages.find_by_id(params[:id])
    @message.destroy
    flash[:notice] = "The message has been deleted."
    redirect_to messages_path(:page => params[:page])
  end
end
