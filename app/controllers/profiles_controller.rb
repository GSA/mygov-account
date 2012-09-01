class ProfilesController < ApplicationController
  before_filter :oauthorize
  
  def show
    unless @token.valid?
      render :json => {:status => 'Error', :message => "You do not have access to read that user's profile."}, :status => 403
    else
      respond_to do |format|
        format.json {
          if @user
            if params[:schema].present?
              render :json => {:status => 'OK', :user => @user.to_schema_dot_org_hash }
            else
              render :json => {:status => 'OK', :user => @user }
            end
          else
            render :json => {:status => 'Error', :message => 'Profile not found' }, :status => 404
          end
        }
      end
    end
  end
end