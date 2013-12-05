require 'spec_helper'

describe "Activity Log" do
  before do
    create_confirmed_user_with_profile

    @app1 = @user.apps.create(name: 'Public App 1', :short_description => 'Public Application 1', :description => 'A public app 1', redirect_uri: "http://localhost/")
    @app1.is_public = true
    @app1.save!
  end

  describe "GET /activity_log" do
    context "when the user is logged in" do
      before {login(@user)}

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

        it "shows the user that their profile has been accessed in the activity log with a time stamp" do
          get "/api/profile", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
          response.code.should == "200"
          login(@user)
          visit activity_log_path
          expect(page).to have_content("#{@app1.name} viewed your profile at #{@user.app_activity_logs.first.created_at.strftime('%H:%M %p')}")
        end

        it "shows the user that a notification has been created in the activity log with a time stamp" do
          post "/api/notifications", {:notification => {:subject => 'Project MyUSA', :body => 'This is a test.', :identifier => 'my-app-identifier', :delivery_type => 'email'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}
          response.code.should == "200"
          login(@user)
          visit activity_log_path
          expect(page).to have_content("#{@app1.name} pushed a notification at #{@user.app_activity_logs.first.created_at.strftime('%H:%M %p')}")
        end

        it "shows the user only the last ten API activities" do
          post "/api/notifications", {:notification => {:subject => 'Project MyUSA', :body => 'This is a test.'}}, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"}

          10.times { get "/api/profile", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token.token}"} }

          login(@user)
          visit activity_log_path
          expect(page).to have_content('Account Activity')
          expect(page).to have_selector('ul.activity_list li', :count => 10)
          expect(page).to have_no_content("#{@app1.name} created a notification")
        end
      end
  end
end
