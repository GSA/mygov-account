class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_user
  
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
  
  private
  
  def assign_user
    @user = current_user
  end
end
