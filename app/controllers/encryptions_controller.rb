class EncryptionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_user

  def show
  end

  def edit    
    render :edit
  end

  def create
    pp "STORE USER KEY NAME AND REDIRECT!"

    if @user
      pp "FOUND USER", @user
      @user.update_attribute(:key_storage_name, params[:key_name])
    end

    redirect_to edit_profile_path
  end

end
