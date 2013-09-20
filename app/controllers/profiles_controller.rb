class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_user
  before_filter :assign_profile
  
  def show
  end

  def edit
  end

  def update

    if params[:profile][:is_encrypted] == "1"
      ### "ENCRYPTED, SO SKIP VALIDATIONS"
      @profile.attributes = params[:profile]
      @profile.save(validate: false)
      redirect_to profile_path
    else
      if @profile.update_attributes(params[:profile])
        flash[:notice] = "Your profile was successfully updated."
        redirect_to profile_path
      else
        flash.now[:error] = "Something went wrong."
        render :edit
      end
    end
  end

  private
  
  def assign_profile
    @profile = @user.profile
  end
end
