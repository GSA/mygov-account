require 'spec_helper'
app_names = %w[App1 App2 App3]
describe "OauthApps" do  
  before do
    create_approved_beta_signup('joe@citizen.org')
    @user = User.create!(:email => 'joe@citizen.org', :password => 'random', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
    @user.confirm!
    
    create_approved_beta_signup('second@user.org')
    @user2 = User.create!(:email => 'second@user.org', :password => 'random', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
    @user2.confirm!
        
    app1 = App.create(name: 'App1', redirect_uri: "http://localhost/", user: @user)
    @app1_client = app1.oauth2_client
    app2 = App.create(name: 'App2', redirect_uri: "http://localhost/", user: @user)
    @app2_client = app2.oauth2_client
    app3 = App.create(name: 'App3', redirect_uri: "http://localhost/", user: @user)
    @app3_client = app3.oauth2_client
    default_app  = App.create(name: 'Default App'){|app| app.redirect_uri = "http://localhost/"}
    @default_client = default_app.oauth2_client
  end
  
  describe "it should display a list of apps" do
    it "should display a list of apps" do
      visit(apps_path)
      page.should have_content "App1"
      page.should have_content "App2"
      page.should have_content "App3"
      page.should have_no_content "Default App"
    end
  end
  
  context "user is signed in" do
    before do
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
          within('h3', :text => 'App2') do
            page.should have_content('Authorized')
          end
          
          click_link('App2')
          click_link('Revoke access')
          page.should_not have_content('Revoke access')
        end  
        
        it "should allow a user to revoke access an authorized app" do
          visit(apps_path)
          click_link('App2')
          click_link('Revoke access')
          current_url.should have_content("apps/app2") # Make sure you're still on app page
          page.should_not have_content('Revoke access')          
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
    
    context "user wants to create a sandbox app" do
      it "should display oauth2_client secret upon app create" do
        visit(new_app_path)
        fill_in 'app_name', :with => 'my sandbox app'
        fill_in 'app_url',          :with => 'http://www.myapp.com'
        fill_in 'app_redirect_uri', :with => 'http://www.myapp.com'
        click_button('Continue')
        page.should have_content("Secret:")
        page.text.should match(/Secret: [a-zA-Z0-9]+/)
        page.text.should match(/Client id: [a-zA-Z0-9]+/)
      end

      it "should not display sandbox app in apps index" do
        sandbox = create_sandbox_app(@user)
        visit(apps_path)
        page.should_not have_content("sandbox")        
      end

      it "should allow owner to visit edit page" do
        sandbox = create_sandbox_app(@user)
        visit(edit_app_path(sandbox))
        page.should have_content("Edit")        
      end

      it "should not allow non owner to visit edit page" do
        sandbox = create_sandbox_app(@user)
        create_logged_in_user(@user2)
        visit(edit_app_path(sandbox))
        page.should_not have_content("Edit")        
      end
    end
  end
end
