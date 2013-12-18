class Api::V1::ProfilesController < Api::ApiController
  before_filter :validate_oauth
  
  def show
    scope_list = @token.authorization.scope.split(" ")
    filtered_profile = @user.profile.filtered_profile(scope_list)
    if params[:schema].present?
      render :json => filtered_profile.to_schema_dot_org_hash(scope_list)
    else
      # Limit profile attributes to just those chosen by app owner during app registration.
      render :json => filtered_profile.as_json(:scope_list => scope_list).merge("uid" => @user.uid, "id" => @user.uid)
    end
  end
end