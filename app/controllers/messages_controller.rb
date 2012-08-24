class MessagesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_user
  
  def index
    @messages = @user.messages.paginate(:page => params[:page], :per_page => 10).order('received_at DESC')
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
