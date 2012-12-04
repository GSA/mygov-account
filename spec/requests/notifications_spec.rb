require 'spec_helper'

describe "Notifications" do
  before do
    create_approved_beta_signup('joe@citizen.org')
    @user = User.create!(:email => 'joe@citizen.org', :password => 'random', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
    @user.confirm!
    create_approved_beta_signup('jane@citizen.org')
    @other_user = User.create!(:email => 'jane@citizen.org', :password => 'random', :first_name => 'Jane', :last_name => 'Citizen', :name => 'Jane Citizen')
    @app1 = App.create!(:name => 'App1'){ |app| app.redirect_uri = 'http://localhost/' }
    @app2 = App.create!(:name => 'App2'){ |app| app.redirect_uri = 'http://localhost/' }
    create_logged_in_user(@user)
  end

  describe "GET /notifications" do
    it "should have a title that says 'Notifications'" do
      visit notifications_path
      page.should have_content 'Notifications'
    end
    
    context "when the user has no notifications" do
      before do
        @user.notifications.destroy_all
      end
      
      it "should inform the user they have no notifications" do
        visit notifications_path
        page.should have_content "You currently have no notifications."
      end
    end
    
    context "when the user has notifications" do
      before do
        Notification.all.each { |notification| notification.destroy(:force) }
        1.upto(14) do |index|
          @notification = Notification.create!(:subject => "Notification ##{index}", :received_at => (Time.now - 1.hour + index.minutes), :body => "This is notification ##{index}.", :user_id => @user.id, :app_id => @app1.id)
        end
        @other_user_notification = Notification.create!(:subject => 'Other User Notification', :received_at => (Time.now - 1.hour + 15.minutes), :body => 'This is a notification for a different user.', :user_id => @other_user.id, :app_id => @app1.id)
        @other_app_notification = Notification.create!(:subject => 'Other App Notification', :received_at => (Time.now - 1.hour + 16.minutes), :body => 'This is a notification for a different app.', :user_id => @user.id, :app_id => @app2.id)
      end
      
      it "should put indicate such on the dashboard" do
        visit dashboard_path
        page.should have_content "15"
      end
      
      context "when notifications have been deleted" do
        before do
          @user.notifications.first.destroy
        end
        
        it "should show a count for only the non-deleted notifications" do
          visit dashboard_path
          page.should have_content "14"
        end
      end
      
      context "when some notifications do not have an associated app" do
        before do
          @user.notifications.create!(:subject => 'Appless notification', :received_at => Time.now)
        end
        
        it "should load the page just fine" do
          visit notifications_path
          page.should have_content "Appless notification"
        end
      end
      
      it "should display a paginated list of user's notifications" do
        visit notifications_path
        @user.notifications.not_deleted.newest_first[0..9].each_with_index do |notification, index|
          page.should have_content notification.subject
        end
        click_link('2')
        14.downto(6) do |index|
          page.should_not have_content "Notification ##{index}"
        end
        5.downto(1) do |index|
          page.should have_content "Notification ##{index}"
        end
        click_link('Remove')
        page.should_not have_content "Notification #5"
        page.should_not have_content "Notification #7"
      end

      it "should show the notification in detail and allow the user to delete it" do
        visit notifications_path
        page.should_not have_content "Notification #5"
        click_link "Notification #9"
        page.should have_content "Notifications"
        page.should have_content "Notification #9"
        page.should have_content "This is notification #9"
        click_link "Remove"
        page.should have_content "Notification #5"
        page.should_not have_content "Notification #9"
      end

      it "should revive a deleted record after first removing it" do
        visit notifications_path
        click_link "Notification #7"
        click_link "Remove"
        page.should_not have_content "Notification #7"
        Notification.find_by_subject("Notification #7").revive
        visit notifications_path
        page.should have_content "Notification #7"
      end

      it "should not allow a notification to be deleted twice" do
        visit notifications_path
        click_link "Notification #7"
        Notification.find_by_subject("Notification #7").destroy
        visit notifications_path
        click_link "Remove"
        page.should have_content "Notification #8"
        page.should_not have_content "Notification #7"
        Notification.find_by_subject("Notification #7").deleted_at.should_not eq nil
      end
    end
  end
end