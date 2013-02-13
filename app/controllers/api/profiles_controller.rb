class Api::ProfilesController < Api::ApiController
  before_filter :validate_oauth
  
  def show
    if params[:schema].present?
      render :json => {:status => 'OK', :user => @user.profile.to_schema_dot_org_hash }
    else
      render :json => {:status => 'OK', :user => @user.profile }
    end
  end
end