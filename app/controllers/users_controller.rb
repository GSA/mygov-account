class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_user

  def destroy
    sign_out :user
    @user.destroy
  end

  def edit
    @user = current_user
  end

  def edit_password
    @user = current_user
  end

  def update_password
    @user = User.find(current_user.id)
    new_params =  {password: params[:user][:password]}
    if @user.update_attributes(new_params)
      # Sign in the user by passing validation in case his password changed
      sign_in @user, :bypass => true
      flash[:notice] = "Your password was sucessfully updated."
      redirect_to account_index_path
    else
      @user
      render 'edit_password'
    end
  end
end
