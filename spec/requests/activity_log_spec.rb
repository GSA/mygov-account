require 'spec_helper'

describe "Activity Log" do
  before do
    create_approved_beta_signup('joe@citizen.org')
    @user = User.create!(:email => 'joe@citizen.org', :password => 'Password1')
    @user.confirm!

    @app1 = @user.apps.create(name: 'Public App 1', :short_description => 'Public Application 1', :description => 'A public app 1', redirect_uri: "http://localhost/")
    @app1.is_public = true
    @app1.save!
  end

  describe "GET /activity_log" do
    context "when the user is logged in" do
      before do
        login(@user)
      end

      it "gives the user a friendly message" do
        visit activity_log_path
        page.should have_content("No activity to report.")
      end

    end
      context "when the user has authorized an app" do
        before do
          @app1.oauth_scopes = OauthScope.all
          authorization = OAuth2::Model::Authorization.new
          authorization.scope = @app1.oauth_scopes.collect{ |s| s.scope_name }.join(" ")
          authorization.client = @app1.oauth2_client
          authorization.owner = @user
          access_token = authorization.generate_access_token
          client = OAuth2::Client.new(@app1.oauth2_client.client_id, @app1.oauth2_client.client_secret, :site => 'http://localhost/', :token_url => "/oauth/authorize")
          @token = OAuth2::AccessToken.new(client, access_token)
        end

        it "should show the user in the activity log when their profile has been accessed" do
          get "/api/profile", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
          response.code.should == "200"
          login(@user)
          visit activity_log_path
          expect(page).to have_content("#{@app1.name} viewed your profile")
        end

        it "should show the user in the activity log that a notification has been created" do
          post "/api/notifications", {:notification => {:subject => 'Project MyUSA', :body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
          response.code.should == "200"
          login(@user)
          visit activity_log_path
          expect(page).to have_content("#{@app1.name} pushed a notification")
        end
      end
  end
end
