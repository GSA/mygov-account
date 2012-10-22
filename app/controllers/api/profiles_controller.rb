class Api::ProfilesController < Api::ApiController
  
  def show
    unless @token.valid?
      render :json => {:status => 'Error', :message => "You do not have access to read that user's profile."}, :status => 403
    else
      @user = @token.owner
      if params[:schema].present?
        render :json => {:status => 'OK', :user => @user.to_schema_dot_org_hash }
      else
        render :json => {:status => 'OK', :user => @user }
      end
    end
  end
end