class Api::ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :oauthorize

  def oauthorize
    @user = User.find_by_id(params[:id])
    @token = OAuth2::Provider.access_token(@user, [], request)
  end
end