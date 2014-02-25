require 'spec_helper'

describe "HomePage" do
  before do
    @user = create_confirmed_user_with_profile
  end

  describe "GET /" do
    it "sets secure headers (X-Frame-Options, X-XSS-Protection, and X-XRDS-Location)" do
      # NOTE: the app also sets X-Content-Type-Options: nosniff, but that is only set for IE browsers
      visit root_url

      expect(page.response_headers["X-Frame-Options"]).to eq "SAMEORIGIN"
      expect(page.response_headers["X-XSS-Protection"]).to eq "1; mode=block"
      expect(page.response_headers["X-XRDS-Location"]).to eq "https://www.example.com/xrds.xml"
    end

    context "when not logged in" do
      context "when signing up for the beta" do
        before do
          BetaSignup.destroy_all
          ActionMailer::Base.deliveries = []
        end

        it "should not let a user sign up for the beta without providing their email address" do
          visit root_path
          fill_in 'beta_signup_email', :with => ''
          click_button "Sign Up"
          page.should_not have_content("Thanks for signing up")
          page.should have_content("Email can't be blank")
        end

        it "should let a user sign up for the beta by providing their email address" do
          visit root_path
          fill_in 'beta_signup_email', :with => 'joe@citizen.org'
          click_button "Sign Up"
          BetaSignup.find_by_email('joe@citizen.org').should_not be_nil
          page.should have_content("Thanks for signing up")
        end

        it "should prevent clickjacking and advertise our XRDS file" do
          get "/"
          response.headers['X-Frame-Options'].should == "SAMEORIGIN"
          response.headers['X-XRDS-Location'].should =~ /xrds\.xml/
        end
      end

      context "when the user views a static page" do
        it "should serve the terms of service" do
          visit terms_of_service_path
          page.should have_content "Terms of Service"
        end

        it "should serve the unauthorized access warning" do
          visit terms_of_service_path
          page.should have_content "This computer system is for authorized users only. Unauthorized use or improper use of this system is strictly prohibited. Any use of this system may be monitored or recorded. Evidence of unauthorized use or improper use may be provided to company management and/or law enforcement officials for criminal, administrative or adverse action. By continuing to use this system, you indicate your consent to all conditions stated in this warning. Discontinue use of this system immediately if you are not an authorized user or do not agree to the conditions of this warning statement."
        end

        it "should serve the privacy policy" do
          visit privacy_policy_path
          page.should have_content "Privacy policy"
        end
      end
    end
  end

  context "when already logged in" do
    before {login(@user)}

    it "should show the user the dashboard" do
      visit root_path
      page.should have_content "MyUSA"
      expect(page.current_url).to eq 'http://citizen.org/dashboard'
      page.should have_content 'Joe Citizen'
    end

    context "when the user does not have a first, last or any other name" do
      before do
        @user.profile.update_attributes(:first_name => nil, :last_name => nil)
      end

      it "should link to the profile page with 'Your profile'" do
        visit root_path
        page.should have_content "Account Settings"
        click_link "Account Settings"
        page.find('h2').should have_content "My Profile"
      end
    end


    context "when the user does not have tasks" do
      before { @user.tasks.destroy_all }

      it "should tell the user they currently have no tasks" do
        visit root_path
        page.should have_content "You currently have no tasks."
      end
    end

    context "when the user has tasks with task items" do
      before do
        @app = App.create!(:name => 'Change your name', :redirect_uri => "http://localhost:3000/")
        @user.tasks.create!({:name => 'Change your name', :app_id => @app.id}, :as => :admin)
      end

      it "should show the tasks on the dashboard" do
        visit root_path
        page.should have_content "MyUSA"
        page.should have_content "Tasks"
        page.should have_content "Change your name"
      end
    end

    context "when the user visits the page the first time" do
      before do
        @user.tasks.destroy_all
        @user.notifications.destroy_all
      end

      it "should show the user the dashboard, and link to their resources, and tell them they have no notifications or tasks" do
        visit root_path
        page.should have_content "MyUSA"
        page.should have_content "Profile"
        page.should have_content "Notifications"
        page.should have_content "Tasks"
        page.should have_content "Apps"
        page.should have_content "Terms of service"
        page.should have_content "Privacy policy"
        page.should have_link 'View your profile', :href => profile_path
        page.should have_link 'View all notifications', :href => notifications_path
        page.should have_link 'View all tasks', :href => tasks_path
        page.should have_link 'Learn how to create your own MyUSA app', :href => developer_path
        page.should have_content "You currently have no notifications."
        page.should have_content "You currently have no tasks."
      end
    end
  end

  context "when the user has notifications" do
    before do
      @app = create_public_app_for_user(@user, "Notification App")
      1.upto(10) do |index|
        notification = Notification.new(:subject => "Notification ##{index}", :body => "This is notification ##{index}.", :received_at => Time.now, :notification_type =>'my-alert')
        notification.user = @user
        notification.app = @app
        notification.save!
      end

      login(@user)
    end

    it "should show the first three newest notifications with unread ones in bold" do
      visit root_path
      notifications = Notification.where(deleted_at: nil).order('received_at DESC, id DESC').limit(3).all
      notifications.each_with_index do |notification, index|
        page.should have_content "Notification ##{10 - index}"
        notification.viewed_at.should eq nil
        page.should have_selector("strong", :text => "Notification ##{10 - index}")
      end
      page.should have_content 'Notification App'
      page.should have_content 'less than a minute ago'
      click_link 'Notification #10'
      page.should have_content 'This is notification #10'

      # Now the viewed one should not be highlighted any more, but the others should
      visit root_path
      notifications = Notification.where(deleted_at: nil).order('received_at DESC, id DESC').limit(3).all
      notifications.each_with_index do |notification, index|
        notification_subject_str = notification.subject
        page.should have_content notification_subject_str
        if notification_subject_str == "Notification #10"
          notification.viewed_at.should_not eq nil
          page.should_not have_selector("strong", :text => notification_subject_str)
        else
          notification.viewed_at.should eq nil
          page.should have_selector("strong", :text => notification_subject_str)
        end
      end
    end
  end

  context "when the user has tasks" do
    before do
      @app = create_public_app_for_user(@user, "Task App")
      1.upto(5) do |index|
        task = Task.new(:name => "Task ##{index}")
        task.app = @app
        task.user = @user
        task.save!
      end
      @tasks = @user.tasks.order("created_at DESC", 'id DESC').limit(3)

      login(@user)
    end

    it "should show the first three newest uncompleted tasks" do
      visit root_path
      @tasks.each do |task|
        page.should have_content task.name
      end
      page.should have_content "Task App"
      click_link @tasks.first.name
      page.should have_content @tasks.first.name
    end
  end

  describe "GET /privacy-policy" do
    it "should show the privacy policy" do
      visit privacy_policy_path
      page.should have_content "Privacy policy"
    end
  end

  describe "GET /terms-of-service" do
    it "should show the terms of service" do
      visit terms_of_service_path
      page.should have_content "Terms of service"
    end
  end

  describe "GET /xrds.xml" do
    it "should return the XRDS file" do
      get "/xrds.xml"
      response.headers['Content-Type'].should == "application/xrds+xml; charset=utf-8"
      response.body.should =~ /XRDS/
    end
  end
end

