class EncryptionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_user

  def show
    render :show
  end

  def edit    
    render :edit
  end

  def create

    if @user
      if @user.valid_password?(params[:password])
        @user.update_attribute(:key_storage_name, params[:key_name])
        redirect_to edit_profile_path({:first_encrypt => 'yes'})
      else
        flash[:error] = "password must be entered, and match your login password!"
        render :edit
      end

    end

  end

end
