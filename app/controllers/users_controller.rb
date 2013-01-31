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
      flash.now[:error] = "Something went wrong."
      render :edit
    end
  end
  
  def destroy
    sign_out :user
    @user.destroy
  end
end
