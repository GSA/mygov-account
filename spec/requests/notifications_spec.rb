require 'spec_helper'

describe "Notifications" do
  before do
    BetaSignup.create!(:email => 'joe@citizen.org', :is_approved => true)
    @user = User.create!(:email => 'joe@citizen.org', :password => 'random', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
    @user.confirm!
    BetaSignup.create!(:email => 'jane@citizen.org', :is_approved => true)
    @other_user = User.create!(:email => 'jane@citizen.org', :password => 'random', :first_name => 'Jane', :last_name => 'Citizen', :name => 'Jane Citizen')
    @app1 = OAuth2::Model::Client.new(:name => 'App1', :redirect_uri => 'http://localhost/')
    @app1.oauth2_client_owner_type = 'User'
    @app1.oauth2_client_owner_id = @user.id
    @app1.save!
    @app1_client_secret = @app1.client_secret
    @app2 = OAuth2::Model::Client.new(:name => 'App2', :redirect_uri => 'http://localhost/')
    @app2.oauth2_client_owner_type = 'User'
    @app2.oauth2_client_owner_id = @user.id
    @app2.save!
    create_logged_in_user(@user)
  end

  describe "GET /notifications" do
    context "when the user has no notifications" do
      it "should inform the user they have no notifications" do
        visit notifications_path
        page.should have_content "You currently have no notifications."
      end
    end
    
    context "when the user has notifications" do
      before do
        1.upto(14) do |index|
          @notification = Notification.new(:subject => "Notification ##{index}", :received_at => Time.now - 1.hour, :body => "This is notification ##{index}.")
          @notification.user_id = @user.id
          @notification.o_auth2_model_client_id = @app1.id
          @notification.save!
        end
        @other_user_notification = Notification.new(:subject => 'Other User Notification', :received_at => Time.now - 1.hour, :body => 'This is a notification for a different user.')
        @other_user_notification.user_id = @other_user.id
        @other_user_notification.o_auth2_model_client_id = @app1.id
        @other_app_notification = Notification.new(:subject => 'Other App Notification', :received_at => Time.now - 1.hour, :body => 'This is a notification for a different app.')
        @other_app_notification.user_id = @user.id
        @other_app_notification.o_auth2_model_client_id = @app1.id
      end
      
      it "should display a paginated list of user's notifications" do
        visit notifications_path
        1.upto(10) do |index|
          page.should have_content "Notification ##{index}"
        end
        page.should_not have_content "Notification #11"
        page.should_not have_content "Other User Notification"
        page.should_not have_content "Other App Notification"
        click_link('2')
        2.upto(10) do |index|
          page.should_not have_content "Notification ##{index}"
        end
        11.upto(14) do |index|
          page.should have_content "Notification ##{index}"
        end
        click_link('Delete')
        page.should_not have_content "Notification #9"
        page.should_not have_content "Notification #11"
      end

      it "should show the notification in detail and allow the user to delete it" do
        visit notifications_path
        click_link "Notification #9"
        page.should have_content "Notification #9"
        page.should have_content "This is notification #9"
        click_link "Delete"
        page.should have_content "Notification #2"
        page.should_not have_content "Notification #9"
      end
    end
  end
end