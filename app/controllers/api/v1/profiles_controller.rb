class Api::V1::ProfilesController < Api::ApiController
  before_filter :validate_oauth
  
  def show
    scope_list = @token.authorization.scope.split(" ")
    if params[:schema].present?
      render :json => @user.profile.to_schema_dot_org_hash(scope_list)
    else
      render :json => @user.profile.as_json(:scope_list => scope_list).merge(:uid => @user.uid, :id => @user.uid)
    end
  end
end