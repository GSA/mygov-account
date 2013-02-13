class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_user
  
  def destroy
    sign_out :user
    @user.destroy
  end
end
