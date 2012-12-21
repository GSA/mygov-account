require 'spec_helper'

describe "OauthApps" do  
  describe "it should display a list of apps" do
    it "should display a list of apps" do
      visit(apps_path)
    end
  end
  
  context "user is signed in" do
    before do
      # Create a user
      create_approved_beta_signup('joe@citizen.org')
      @user = User.create!(:email => 'joe@citizen.org', :password => 'random', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
      @user.confirm!
      # Create several apps and clients
      app1 = App.create(name: 'App1'){|app| app.redirect_uri = "http://localhost/"}
      @app1_client = app1.oauth2_client
      app2 = App.create(name: 'App2'){|app| app.redirect_uri = "http://localhost/"}
      @app2_client = app2.oauth2_client
      app3 = App.create(name: 'App3'){|app| app.redirect_uri = "http://localhost/"}
      @app3_client = app3.oauth2_client
      create_logged_in_user(@user)
    end

    describe "it should display all available apps, with none belonging to current user" do
      it "should list all apps" do
        visit(apps_path)
        page.should have_content("App1")
        page.should have_content("App2")
        page.should have_content("App3")
        page.should_not have_content("Authorized")
      end  

      it "should redirect to app's description page when app slug is clicked" do
        visit(apps_path)
        click_link('App1')
        current_url.should have_content("apps/app1")
      end
    end  

    context "user has approved a client" do
      before do
        # Create authorization
        @user.grant_access!(@app2_client, scopes: nil, duration: nil)
      end

      describe "it should indicate which app belongs to user" do
        it "should list all apps" do
          visit(apps_path)
          within('h5', :text => 'App2') do # omit |ref|
            page.should have_content('Authorized')
          end
        end  
      end  
    end
  end
end
