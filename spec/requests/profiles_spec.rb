require 'spec_helper'

describe "Profiles" do
  before do
    @user = User.create(:email => 'joe@citizen.org', :first_name => 'Joe', :last_name => 'Citizen', :provider => 'google')
    @app = OAuth2::Model::Client.new(:name => 'App1', :redirect_uri => 'http://localhost/')
    @app.oauth2_client_owner_type = 'User'
    @app.oauth2_client_owner_id = @user.id
    @app.save!
  end
  
  describe "GET /profiles/:id.json" do
    context "when the request has a valid token" do
      before do
        authorization = OAuth2::Model::Authorization.new
        authorization.client = @app
        authorization.owner = @user
        access_token = authorization.generate_access_token
        client = OAuth2::Client.new(@app.client_id, @app.client_secret, :site => 'http://localhost/', :token_url => "/oauth/authorize")
        @token = OAuth2::AccessToken.new(client, access_token)
      end

      context "when the user queried exists" do
        it "should return JSON with the profile information for the profile specificed" do
          get "/profiles/#{@user.id}.json", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
          parsed_json = JSON.parse(response.body)
          parsed_json["status"].should == "OK"
          parsed_json["user"]["email"].should == "joe@citizen.org"
          parsed_json["user"]["provider"].should be_nil
        end
      end
    
      context "when the user does not exist" do
        it "should return an error message" do
          get "/profiles/#{@user.id + 1}.json", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
          parsed_json = JSON.parse(response.body)
          parsed_json["status"].should == "Error"
          parsed_json["message"].should == "Profile not found"
        end
      end
    end
    
    context "when the request does not have a valid token" do
      it "should return an error message" do
        get "/profiles/#{@user.id + 1}.json", nil, {'HTTP_AUTHORIZATION' => "Bearer bad_token"}
        parsed_json = JSON.parse(response.body)
        parsed_json["status"].should == "Error"
        parsed_json["message"].should == "You do not have access to read that user's profile."
      end
    end
  end
end