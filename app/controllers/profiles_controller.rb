class ProfilesController < ApplicationController
  
  def show
    @user = User.find_by_id(params[:id])
    @token = OAuth2::Provider.access_token(@user, [], request)
    unless @token.valid?
      render :json => {:status => 'Error', :message => "You do not have access to read that user's profile."}, :status => 403
    else
      respond_to do |format|
        format.json {
          if @user
            render :json => {:status => 'OK', :user => @user }
          else
            render :json => {:status => 'Error', :message => 'Profile not found' }, :status => 404
          end
        }
      end
    end
  end
end