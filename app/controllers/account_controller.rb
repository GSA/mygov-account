class AccountController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_user

  def index
    redirect_to profile_path
  end

  def change_password
    render 'devise/passwords/edit'
  end
end
