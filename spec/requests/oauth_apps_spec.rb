require 'spec_helper'

describe "OauthApps" do
  before do
    create_approved_beta_signup('joe@citizen.org')
    @user = User.create!(:email => 'joe@citizen.org', :password => 'random', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
    @user.confirm!

    create_approved_beta_signup('second@user.org')
    @user2 = User.create!(:email => 'second@user.org', :password => 'random', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
    @user2.confirm!

    OauthScope.seed_data.each { |os| OauthScope.create os }
    app1 = App.create(name: 'App1'){|app| app.redirect_uri = "http://localhost/"}
    app1.oauth_scopes << OauthScope.all
    @app1_client_auth = app1.oauth2_client
    app2 = App.create(name: 'App2'){|app| app.redirect_uri = "http://localhost/"}
    @app2_client_auth = app2.oauth2_client
    app3 = App.create(name:  'App3'){|app| app.redirect_uri = "http://localhost/"}
    @app3_client_auth = app3.oauth2_client

    sandbox = App.create(name:  'sandbox', status: "sandbox", user_id: @user.id){|app| app.redirect_uri = "http://localhost/"}
    @sandbox_client_auth = sandbox.oauth2_client

  end
  
  context "when logged in" do
    before do
      create_logged_in_user(@user)
    end
    describe "Authorize sandbox application by owner" do
      it "should ask for authorization and redirect after clicking 'Allow'" do
        visit(url_for(controller: 'oauth', action: 'authorize',
              response_type: 'code', client_id: @sandbox_client_auth.client_id, redirect_uri: 'http://localhost/'))
        page.should have_content('The sandbox application wants to:')
        click_button('Allow')
        uri = URI.parse(current_url)
        params = CGI::parse(uri.query)
        code = (params["code"] || []).first
        code.should_not be_empty
      end
    end
  end

  context "when logged in" do
    before do
      create_logged_in_user(@user2)
    end
    describe "Does not allow sandbox application installation by non owner" do
      it "code in params should not have a value" do
        visit(url_for(controller: 'oauth', action: 'authorize',
              response_type: 'code', client_id: @sandbox_client_auth.client_id, redirect_uri: 'http://localhost/'))
        page.should have_content('The sandbox application wants to:')
        click_button('Allow')
        uri = URI.parse(current_url)
        params = CGI::parse(uri.query)
        params["error"].should have_content("access_denied")
      end
    end
  end

  describe "Authorize application" do
    it "should redirect to a login page to authorize a new app" do
      get(url_for(controller: 'oauth', action: 'authorize',
              response_type: 'code', client_id: @app1_client_auth.client_id, redirect_uri: 'http://localhost/')
      ).should redirect_to(sign_in_path)
    end
  end

  context "when logged in" do
    before do
      create_logged_in_user(@user)
    end
    
    describe "Authorize application" do
      it "should ask for authorization and redirect after clicking 'Allow'" do
        visit(url_for(controller: 'oauth', action: 'authorize',
              response_type: 'code', client_id: @app1_client_auth.client_id, redirect_uri: 'http://localhost/'))
        page.should have_content('The App1 application wants to:')
        page.should_not have_content('Read your profile information')
        page.should_not have_content('Send you notifications')
        page.should_not have_content('Submit forms on your behalf')
        click_button('Allow')
        uri = URI.parse(current_url)
        params = CGI::parse(uri.query)
        code = (params["code"] || []).first
        uri.path.should == "/"
        code.should_not be_empty
        post("/oauth/authorize", "grant_type" => "authorization_code", "code" => code, "client_id" => @app1_client_auth.client_id, "client_secret" => @app1_client_auth.client_secret, "redirect_uri" => "http://localhost/")
        response.code.should == "200"
        response.body.should match /access_token/
      end
    end
    
    describe "Authorize application with scopes" do
      it "should ask for authorization and redirect after clicking 'Allow'" do
        visit(url_for(controller: 'oauth', action: 'authorize',
              response_type: 'code', scope: 'profile submit_forms notifications', client_id: @app1_client_auth.client_id, redirect_uri: 'http://localhost/'))
        page.should have_content('The App1 application wants to:')
        page.should have_content('Read your profile information')
        page.should have_content('Send you notifications')
        page.should have_content('Submit forms on your behalf')
        click_button('Allow')
        uri = URI.parse(current_url)
        params = CGI::parse(uri.query)
        code = (params["code"] || []).first
        uri.path.should == "/"
        code.should_not be_empty
        post("/oauth/authorize", "grant_type" => "authorization_code", "code" => code, "client_id" => @app1_client_auth.client_id, "client_secret" => @app1_client_auth.client_secret, "redirect_uri" => "http://localhost/")
        response.code.should == "200"
        response.body.should match /access_token/
      end
      
      context "when the user does not approve" do
        it "should return an error when trying to authorize" do
          visit(url_for(controller: 'oauth', action: 'authorize',
                response_type: 'code', scope: 'profile submit_forms notifications', client_id: @app1_client_auth.client_id, redirect_uri: 'http://localhost/'))
          page.should have_content('The App1 application wants to:')
          page.should have_content('Read your profile information')
          page.should have_content('Send you notifications')
          page.should have_content('Submit forms on your behalf')
          click_button('Cancel')
          uri = URI.parse(current_url)
          params = CGI::parse(uri.query)
          code = (params["code"] || []).first
          uri.path.should == "/"
          post("/oauth/authorize", "grant_type" => "authorization_code", "code" => code, "client_id" => @app1_client_auth.client_id, "client_secret" => @app1_client_auth.client_secret, "redirect_uri" => "http://localhost/")
          response.code.should_not == "200"
        end
      end
    end
  end
  
  describe "GET /oauth_apps" do
    context "when logged in with a few apps" do
      before do
        create_logged_in_user(@user)
        @app1 = OAuth2::Model::Client.new(:name => 'App1', :redirect_uri => 'http://localhost/')
        @app1.oauth2_client_owner_type = 'User'
        @app1.oauth2_client_owner_id = @user.id
        @app1.save!
        app2 = OAuth2::Model::Client.new(:name => 'App2', :redirect_uri => 'http://localhost/')
        app2.oauth2_client_owner_type = 'User'
        app2.oauth2_client_owner_id = @user.id
        app2.save!
        app3 = OAuth2::Model::Client.new(:name => 'App3', :redirect_uri => 'http://localhost/')
        app3.oauth2_client_owner_type = 'User'
        app3.oauth2_client_owner_id = @user.id + 1
        app3.save!
      end
      
      context "visiting the apps index" do
        before do
          visit oauth_apps_path
        end
      
        it "should provide a link to register a new app" do
          page.should have_content("Register a new Application")
        end
        
        it "should list all the apps for that user" do
          page.should have_content("Your Applications")
          page.should have_content("App1")
          page.should have_content("App2")
          page.should_not have_content("App3")
        end
      end
      
      context "viewing an individual application" do
        before do
          visit oauth_apps_path
        end
        
        it "should show me info about an app" do
          click_link('App1')
          page.should have_content "App1"
          page.should have_content "http://localhost/"
          page.should have_content @app1.client_id
        end
      end
      
      context "editing an application" do
        before do
          visit oauth_apps_path
        end
        
        it "should allow me to update an application's name and redirect url" do
          click_link('Edit')
          fill_in('Name', :with => 'New App^1')
          fill_in('Redirect URI', :with => 'http://localhost2/')
          click_button('Update Application')
          page.should have_content 'App^1'
          page.should_not have_content 'App1'
          page.should have_content 'http://localhost2/'
          page.should_not have_content 'http://localhost/'
        end
      end
      
      context "deleting an application" do
        before do
          visit oauth_apps_path
        end
        
        it "should allow me to delete an app" do
          click_link("Delete")
          page.should_not have_content("Apps1")
        end
      end
    end
  end
end
