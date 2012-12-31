require 'spec_helper'
app_names = %w[App1 App2 App3]
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
      default_app  = App.create(name: 'Default App'){|app| app.redirect_uri = "http://localhost/"}
      @default_client = default_app.oauth2_client
      create_logged_in_user(@user)
    end

    describe "it should display all available apps, with none belonging to current user" do
      it "should list all apps" do
        visit(apps_path)
        app_names.each{|app_name| page.should have_content(app_name)}
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
      describe "it should display all available apps via json api" do
        it "should list all apps, not include info specific to the logged in user, not list Default App, and not list 'app' as root node" do  
          visit(apps_path(:json))
          app_names.each{|app_name| page.should have_content(app_name)}
          page.should_not have_content("\"authorized\":true")
          page.should_not have_content("\[\{\"app\"\:")
        end
      end
    end
  end
end
