class WelcomeController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_user
  
  def index
    @profile = @user.profile
    @step = (params[:step] || "info")
    if params[:profile]
      if @profile.update_attributes(params[:profile])
        task = params[:step] == 'last' ? @user.tasks.last : @user.tasks.first
        task.complete!
      else
        @step = (params[:step] == 'last' ? "about_you" : "info")
      end
    end
    redirect_to dashboard_path if (request.method == "POST" and @profile.errors.empty?) or @step == "last"
  end
end