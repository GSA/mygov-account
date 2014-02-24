require 'spec_helper'

describe "Apps" do  
  before do

    @user = create_confirmed_user_with_profile
    @user2 = create_confirmed_user_with_profile(email: 'jane@citizen.org', first_name: 'Jane')        
    @app1 = @user.apps.create(name: 'Public App 1', :url => 'http://www.agency.gov/app1', :short_description => 'Public Application 1', :description => 'A public app 1', redirect_uri: "http://localhost/")
    @app1.is_public = true
    @app1.save!
    
    @app3 = @user.apps.create(name: 'Public App 3', :url => Capybara.default_host, :short_description => 'Public Application 3', :description => 'A public app 3', redirect_uri: "http://localhost/")
    @app3.is_public = true
    @app3.save!

    @app4 = @user.apps.create(name: 'Public App 4', :short_description => 'Public Application 4', :description => 'A public app 4', redirect_uri: "http://localhost/")
    @app4.is_public = true
    @app4.save!

    @app2 = @user2.apps.create(name: 'Public App 2', :url => 'http://www.agency.gov/app2', :short_description => 'Public Application 2', :description => 'A public app 2', redirect_uri: "http://localhost/")
    @app2.is_public = true
    @app2.save!
    
    @sandboxed_app1 = @user.apps.create(name: 'Sandboxed App 1', :short_description => 'Sandboxed Application 1', redirect_uri: "http://localhost/")
    @sandboxed_app2 = @user2.apps.create(name: 'Sandboxed App 2', :short_description => 'Sandboxed Application 2', redirect_uri: "http://localhost/")
  end
  
  describe "GET /apps" do
    context "when no user is logged in" do
      it "should display a list of public (non-sandboxed) apps" do
        visit apps_path
        page.should have_content "Public App 1"
        page.should have_content "Public App 2"
        page.should have_no_content "Sandboxed App 1"
      end
    end
    
    context "when a user is logged in" do
      before {login(@user)}
      
      it "should not link to leaving page if app has no url" do
        visit apps_path
        click_link "Public App 4"
        page.should_not have_link "Public App 4"

      end

      it "should warn user before redirecting user off site" do
        visit apps_path
        click_link "Public App 1"
        click_link "Public App 1"
        
        page.should have_content I18n.t('leaving_myusa')
        page.should have_content I18n.t('not_part_of_myusa')
        page.should have_css  %Q/meta[content="#{Rails.application.config.apps_leaving_delay};#{URI.escape @app1.url}"]/, :visible => false

        visit apps_path
        click_link "Public App 3"
        click_link "Public App 3"
        
        page.should_not have_content I18n.t('leaving_myusa')
        page.should_not have_content I18n.t('not_part_of_myusa')

        page.should have_content I18n.t('apps_leaving')

      end
      
      it "should show a list of public apps, and those sandboxed apps that are owned by the logged in user" do
        visit apps_path
        page.should have_content "Public App 1"
        page.should have_content "Public App 2"
        page.should have_content "Sandboxed App 1"
        page.should have_no_content "Sandboxed App 2"
        page.should have_no_content "Authorized"
        click_link "Public App 1"
        current_url.should have_content "apps/public-app-1"
      end
      
      context "when the user has authorized an application" do
        before {@user.grant_access!(@app2.oauth2_client, scopes: ["profile"], duration: nil)}
        
        it "should show that the user has authorized that app" do
          visit apps_path
          within('h3', :text => 'Public App 2') {page.should have_content 'Authorized'}
          click_link 'Public App 2'
          click_link('Revoke access')
          current_url.should have_content("apps/public-app-2")
          page.should have_no_content 'Revoke access'
          visit apps_path
          page.should have_no_content 'Authorized'
        end
      end
    end
  end
  
  describe "GET /apps.json" do
    it "should list all apps, not including info specific to the logged in user, not list Default App, and not list 'app' as root node" do  
      get "/apps.json"
      parsed_response = JSON.parse(response.body)
      parsed_response.size.should == 4
    end
  end
  
  describe "GET /apps/new" do
    context "when a user is not logged in" do
      it "should not show the page" do
        visit new_app_path
        page.should have_content "Please sign in or sign up before continuing."
        fill_in_email_and_password
        click_button 'Sign in'
        current_path.should match('apps')
      end
    end
    
    context "when a user is signed in" do
      before {login(@user)}
      
      it "should let a user create a new app, show them the the client id and secret id, and edit the app" do
        visit new_app_path

        page.should have_content('Short Description')
        page.should have_content('URL')
        page.should have_content('Redirect URI')
        page.should have_content("Create tasks in user's account")
        page.should have_content('Send notifications to user')

        fill_in 'Name', :with => 'My sandbox app'
        fill_in 'URL',  :with => 'http://www.myapp.com'
        fill_in 'Description', :with => 'An app!'
        fill_in 'Redirect URI', :with => 'http://www.myapp.com/redirect'
        check("Read user's profile information")
        click_button('Register New MyUSA App')
        page.should have_link 'My sandbox app', :href => "/apps/my-sandbox-app/leaving"
        page.should have_content "An app!"
        page.should have_content("Your application has been created.")
        page.text.should match(/OAuth Client ID: [a-zA-Z0-9]+/)
        page.text.should match(/OAuth Client Secret: [a-zA-Z0-9]+/)
        page.should have_link 'Edit app information'
        click_link('Edit app information')
        fill_in "Description", :with => 'An app$'
        click_button('Update your MyUSA App')
        page.should have_content "An app$"
        page.should have_no_content "An app!"
      end
      
      context "when the user selects scopes but not something else that's required" do
        it "should remember which scopes the user checked" do
          visit new_app_path
          check("Read user's profile information")
          check('Email')
          click_button('Register New MyUSA App')
          profile_scope_id     = OauthScope.where(scope_name: 'profile').first.id
          profile_sub_scope_id = OauthScope.where(scope_name: 'profile.email').first.id
          find("#app_app_oauth_scopes_attributes_#{profile_scope_id}_oauth_scope_id").should be_checked
          find("#app_app_oauth_scopes_attributes_#{profile_sub_scope_id}_oauth_scope_id").should be_checked
        end
      end
      
      context "when the user does not select an OAuth Scope" do
        it "should not create the app and return the user to the form with an error message" do
          visit new_app_path
          fill_in 'Name', :with => 'My sandbox app'
          fill_in 'URL',  :with => 'http://www.myapp.com'
          fill_in 'Description', :with => 'An app!'
          fill_in 'Redirect URI', :with => 'http://www.myapp.com/redirect'
          click_button('Register New MyUSA App')
          page.should have_content "Please select at least one scope."
        end
      end
    end
  end
  
  describe "GET /app/:slug" do
    it "should link to the app home page via an interstitial page that warns the user they are leaving MyUSA" do
      visit app_path @app1
      page.should have_link @app1.name
      click_link @app1.name
      page.should have_content "You are leaving MyUSA"
      page.should have_link @app1.url, :href => @app1.url
    end
    
    context "when a user is not logged in" do
      context "for public apps" do
        it "should show the app page, but not provide a link to edit the app" do
          visit app_path @app1
          page.should have_content @app1.name
          page.should have_content @app1.description
          page.should have_no_link 'Edit'
        end
      end
      
      context "for sandboxed apps" do
        it "should redirect the user to the apps page" do
          visit app_path(@sandboxed_app1)
          page.should have_content "MyUSA Applications"
          page.should have_no_content @sandboxed_app1.name
        end
      end
    end
    
    context "when a user is logged in" do
      before {login(@user)}
      
      context "for the app owner" do
        context "for public apps" do
          it "should show the app page, and a link to edit the app" do
            visit app_path @app1
            page.should have_content @app1.name
            page.should have_content @app1.description
            page.should have_content "App status: Public"
            page.should have_link 'Edit app information'
          end
        end
      
        context "for sandboxed apps" do
          it "show the app page, and a link to edit the app" do
            visit app_path @sandboxed_app1
            page.should have_content @sandboxed_app1.name
            page.should have_content @sandboxed_app1.description
            page.should have_content "App status: Sandboxed"
            page.should have_link 'Edit app information'
          end
        end
      end
      
      context "for a non-owning user" do
        context "for public apps" do
          it "should show the app page, but not link to edit the app" do
            visit app_path @app2
            page.should have_content @app2.name
            page.should have_content @app2.description
            page.should have_no_link 'Edit app information'
          end
        end
      
        context "for sandboxed apps" do
          it "show the app page, redirect to the apps page" do
            visit app_path @sandboxed_app2
            page.should have_content "MyUSA Applications"
            page.should have_no_content @sandboxed_app2.name
          end
        end
      end
      
      context "for an owner-user" do
        context "app can be deleted (not public and no logs)" do
          it "should allow a user to delete an app" do
            visit apps_path
            page.should have_content @sandboxed_app1.name
            visit app_path @sandboxed_app1
            click_link 'Edit app information'
            click_link "Remove"
            current_path.should eq apps_path
            page.should have_no_content @sandboxed_app1.name
          end
        end
        
        context "app can be deleted and matches another deleted app" do
          before do
            @app1.destroy
            @app1 = @user.apps.create(name: 'Public App 1', :url => 'http://www.agency.gov/app1', :short_description => 'Public Application 1', :description => 'A public app 1', redirect_uri: "http://localhost/")
            @app1.is_public = true
            @app1.save!
          end
          
          it "should allow a user to delete an app" do
            visit apps_path
            page.should have_content @sandboxed_app1.name
            visit app_path @sandboxed_app1
            click_link 'Edit app information'
            click_link "Remove"
            current_path.should eq apps_path
            page.should have_no_content @sandboxed_app1.name
          end
        end
        
        context "app cannot be deleted (is public)" do
          it "should not allow a user to delete an app" do
            visit app_path @app1
            click_link 'Edit app information'
            page.should have_no_link 'Remove'
          end
        end
      end
    end
  end
end
