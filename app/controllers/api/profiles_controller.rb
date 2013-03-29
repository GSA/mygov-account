class Api::ProfilesController < Api::ApiController
  before_filter :validate_oauth
  
  def show
    if params[:schema].present?
      render :json => {:status => 'OK', :user => {} }
    else
      render :json => {:status => 'OK', :user => {} }
    end
  end
end