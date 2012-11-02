class WelcomeController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_user
  
  def index
    @step = (params[:step] || "info")
    if params[:user]
      unless @user.update_attributes(params[:user])
        @step = (params[:step] == 'last' ? "about_you" : "info")
      end
    end
    redirect_to dashboard_path if @step == "last"
  end
end