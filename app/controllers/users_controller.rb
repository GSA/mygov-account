class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:new]
  before_filter :assign_user, :except => [:new]
  
  def new
    redirect_to dashboard_path if current_user  
  end
  
  def show
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = "Your profile was sucessfully updated."
      redirect_to profile_path
    else
      flash[:error] = "Something went wrong."
      redirect_to :back
    end
  end    
end
