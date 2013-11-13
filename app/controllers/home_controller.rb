class HomeController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :developer, :privacy_policy, :terms_of_service, :about, :xrds]
  before_filter :assign_user, :except => [:index, :privacy_policy, :developer, :terms_of_service, :xrds]

  def index
    if current_user
      @notice = flash.notice && current_user.profile.name ? "Hi #{current_user.profile.name}. #{flash.notice}" : flash.notice
      redirect_to :dashboard, notice: @notice

    else
      @beta_signup = BetaSignup.new
      render :layout => 'signup'
    end
  end

  def dashboard
    @today = Date.current
    @uncompleted_tasks = @user.tasks.uncompleted.order('created_at DESC')
    @notifications = @user.notifications
    @public_apps = App.where(is_public: true)
    render 'dashboard'
  end

  def developer
  end

  def discovery
  end

  def privacy_policy
  end

  def terms_of_service
  end

  def about
  end

  def pra
  end

  def xrds
    response.content_type = "application/xrds+xml"
  end

  def help
  end
end