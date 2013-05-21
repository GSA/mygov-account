class Api::ProfilesController < Api::ApiController
  before_filter :validate_oauth
  
  def show
    if params[:schema].present?
      render :json => @user.profile.to_schema_dot_org_hash
    else
      render :json => @user.profile
    end
  end
end
