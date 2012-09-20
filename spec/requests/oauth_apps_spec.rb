require 'spec_helper'

describe "OauthApps" do
  before do
    @user = User.create!(:email => 'joe@citizen.org', :password => 'random', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
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
