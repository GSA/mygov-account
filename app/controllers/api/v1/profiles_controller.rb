class Api::V1::ProfilesController < Api::ApiController
  before_filter :validate_oauth
  
  def show
    scope_list = @token.authorization.scope.split(" ")
    if params[:schema].present?
      render :json => @user.profile.to_schema_dot_org_hash(scope_list)
    else
      # Limit profile attributes to just those chosen by app owner during app registration.
      # Select profile attributes whose keys are included in the array of app requestsed profile fields plus user id
      render :json => @user.profile.attributes.select{|k, _| @app.oauth_scopes.select{|os| os.scope_name.match(/^profile\./)}.map(&:scope_name).map{|e| e.sub(/^profile\./, "")}.include? k}.merge(:uid => @user.uid, :id => @user.uid)
      
      # Old
      # render :json => @user.profile.as_json(:scope_list => scope_list).merge(:uid => @user.uid, :id => @user.uid)

    end
  end
end