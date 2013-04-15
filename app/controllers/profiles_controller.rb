class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :assign_user
  before_filter :assign_profile, :only => [:show, :edit, :update]
  
  def show
  end
  
  def edit
  end
  
  def update
    year, month, day = params[:profile].delete(:"date_of_birth(1i)"), params[:profile].delete(:"date_of_birth(2i)"), params[:profile].delete(:"date_of_birth(3i)")
    params[:profile][:date_of_birth] = Date.parse("#{year}-#{month}-#{day}") unless year.blank? or month.blank? or day.blank?
    @profile.update_attributes(params[:profile])
    @profile.store_profile_attributes
    redirect_to profile_path
  end
  
  def authorize
    redirect_to GoogleDriveProvider.new.authorization_url
  end
      
  def authorization_callback
    if params[:code]
      api_client = GoogleDriveProvider.new.client
      api_client.authorization.code = params[:code]
      api_client.authorization.fetch_access_token!
      if @user.profile
        @user.profile.update_attributes(:access_token => api_client.authorization.access_token, :refresh_token => api_client.authorization.refresh_token)
      else
        @profile = @user.build_profile(:provider_name => 'GoogleDriveProvider', :access_token => api_client.authorization.access_token, :refresh_token => api_client.authorization.refresh_token)
        @profile.save
      end
      redirect_to profile_path
    else
      flash[:error] = "Something went wrong in the authorization.  Sorry."
      redirect_to profile_path
    end
  end
  
  private
  
  def assign_profile
    @profile = @user.profile
  end
end