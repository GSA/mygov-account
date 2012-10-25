class WelcomeController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_user
  
  def index
    @user.update_attributes(params[:user]) if params[:user]
    @step = (params[:step] || "info")
    redirect_to dashboard_path if @step == "last"
  end
end