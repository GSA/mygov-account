class Api::ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :oauthorize

  def oauthorize
    @token = OAuth2::Provider.access_token(@user, [], request)
    if @token.valid?
      @app = @token.authorization.client.owner
      @user = @token.owner
    end
  end
end