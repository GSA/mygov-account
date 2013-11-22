require 'spec_helper'

describe "OauthApps" do
  before do
    @user = create_confirmed_user_with_profile
    @user2 = create_confirmed_user_with_profile(email: 'second@user.org')
    
    app1 = App.create(name: 'App1'){|app| app.redirect_uri = "http://localhost/"}
    app1.is_public = true
    app1.save!
    app1.oauth_scopes << OauthScope.top_level_scopes
    @app1_client_auth = app1.oauth2_client
    
    app2 = App.create(name: 'App2'){|app| app.redirect_uri = "http://localhost/"}
    app2.is_public = true
    app2.save!
    @app2_client_auth = app2.oauth2_client
    
    app3 = App.create(name:  'App3'){|app| app.redirect_uri = "http://localhost/"}
    app3.is_public = true
    app3.save!
    @app3_client_auth = app3.oauth2_client

    @sandbox = App.create({name:  'sandbox', user_id: @user.id, redirect_uri: "http://localhost/"}, :as => :admin)
    @sandbox_client_auth = @sandbox.oauth2_client
  end
  
  context "when logged in with a user who owns a sandboxed app" do
    before {login(@user)}
    
    describe "Authorize sandbox application by owner" do
      it "should ask for authorization and redirect after clicking 'Allow'" do
        visit(url_for(controller: 'oauth', action: 'authorize', response_type: 'code', client_id: @sandbox_client_auth.client_id, redirect_uri: 'http://localhost/'))
        page.should have_content('The sandbox application wants to:')
        click_button('Allow')
        uri = URI.parse(current_url)
        params = CGI::parse(uri.query)
        code = (params["code"] || []).first
        code.should_not be_empty
      end

      it "should log the sandbox application authorization activity, associated with the user" do
        visit(url_for(controller: 'oauth', action: 'authorize', response_type: 'code', client_id: @sandbox_client_auth.client_id, redirect_uri: 'http://localhost/'))
        page.should have_content('The sandbox application wants to:')
        click_button('Allow')
        @user.app_activity_logs.count.should == 1
        @user.app_activity_logs.first.app.should == @sandbox
      end
    end
  end

  context "when logged in with a user who does not own the sandboxed app" do
    before {login(@user2)}
    
    describe "Does not allow sandbox application installation by non owner" do
      it "code in params should not have a value" do
        visit(url_for(controller: 'oauth', action: 'authorize', response_type: 'code', client_id: @sandbox_client_auth.client_id, redirect_uri: 'http://localhost/'))
        page.should have_content('The sandbox application wants to:')
        click_button('Allow')
        uri = URI.parse(current_url)
        params = CGI::parse(uri.query)
        params["error"].should have_content("access_denied")
      end
    end
  end

  describe "Authorize application" do
    context "when the app is known" do
      it "should redirect to a login page to authorize a new app" do
        get(url_for(controller: 'oauth', action: 'authorize',
                response_type: 'code', client_id: @app1_client_auth.client_id, redirect_uri: 'http://localhost/')
        ).should redirect_to(sign_in_path)
      end
    end
    
    context "when the app is sandboxed" do
      it "should allow the user to sign up whitelisted (without going through BetaSignup)" do
        visit(url_for(controller: 'oauth', action: 'authorize',
                response_type: 'code', client_id: @sandbox_client_auth.client_id, redirect_uri: 'http://localhost/')
        )
        uri = URI.parse(current_url)
        uri.path.should eq sign_in_path
        click_link("Sign up")
        fill_in 'Email', with: 'new@user.com'
        fill_in 'Password', with: 'Password1'
        fill_in 'Password confirmation', with: 'Password1'
        check 'I agree to the MyUSA Terms of Service and Privacy Policy'
        click_button('Sign up')
        page.should have_content("I'm sorry, your account hasn't been approved yet.")
      end
    end
    
    context "when the app is public" do
      it "should allow the user to sign up whitelisted (without going through BetaSignup)" do
        visit(url_for(controller: 'oauth', action: 'authorize',
                response_type: 'code', client_id: @app2_client_auth.client_id, redirect_uri: 'http://localhost/')
        )
        uri = URI.parse(current_url)
        uri.path.should eq sign_in_path
        click_link("Sign up")
        fill_in 'Email', with: 'new@user.com'
        fill_in 'Password', with: 'Password1'
        fill_in 'Password confirmation', with: 'Password1'
        check 'I agree to the MyUSA Terms of Service and Privacy Policy'
        click_button('Sign up')
        page.should_not have_content("I'm sorry, your account hasn't been approved yet.")
        page.should have_content("Thank you for signing up")
      end
    end

    context "when the app is not known" do
      it "should redirect to a friendly error page if the app is unknown" do
        visit(url_for(controller: 'oauth', action: 'authorize',
                response_type: 'code', client_id: 'xyz', redirect_uri: 'http://localhost/')
        )
        page.should have_content("We're Sorry")
        page.should have_content("The app you are attempting to use is not known or is not properly identifying itself to MyUSA.")
      end
    end
  end

  context "when logged in" do
    before {login(@user)}
    
    describe "Authorize application" do
      it "should ask for authorization and redirect after clicking 'Allow'" do
        visit(url_for(controller: 'oauth', action: 'authorize',
              response_type: 'code', client_id: @app1_client_auth.client_id, redirect_uri: 'http://localhost/'))
        page.should have_content('The App1 application wants to:')
        page.should_not have_content('Read your profile information')
        page.should_not have_content('Send you notifications')
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

      it "should log the application authorization activity, associated with the user" do
        visit(url_for(controller: 'oauth', action: 'authorize', response_type: 'code', client_id: @app1_client_auth.client_id, redirect_uri: 'http://localhost/'))
        page.should have_content('The App1 application wants to:')
        click_button('Allow')
        @user.app_activity_logs.count.should == 1
        @user.app_activity_logs.first.app.should == App.find_by_name('App1')
      end
    end

    describe "Authorize application with scopes" do
      it "should ask for authorization and redirect after clicking 'Allow'" do
        visit(url_for(controller: 'oauth', action: 'authorize',
              response_type: 'code', scope: 'profile notifications', client_id: @app1_client_auth.client_id, redirect_uri: 'http://localhost/'))
        page.should have_content('The App1 application wants to:')
        page.should have_content('Read your profile information')
        page.should have_content('Send you notifications')
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
                response_type: 'code', scope: 'profile notifications', client_id: @app1_client_auth.client_id, redirect_uri: 'http://localhost/'))
          page.should have_content('The App1 application wants to:')
          page.should have_content('Read your profile information')
          page.should have_content('Send you notifications')
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
end
