class WelcomeController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_user
  
  def index
    @step = (params[:step] || "info")
    if params[:user]
      if @user.update_attributes(params[:user])
        task = params[:step] == 'last' ? @user.tasks.last : @user.tasks.first
        task.complete!
      else
        @step = (params[:step] == 'last' ? "about_you" : "info")
      end
    end
    redirect_to dashboard_path if request.method == "POST" and @user.errors.empty?
  end
end