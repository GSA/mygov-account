class ProfilesController < ApplicationController
  
  def show
    @user = User.find_by_id(params[:id])
    respond_to do |format|
      format.json {
        if @user
          render :json => {:status => 'OK', :user => @user }
        else
          render :json => {:status => 'Error', :message => 'Profile not found' }
        end
      }
    end
  end
end