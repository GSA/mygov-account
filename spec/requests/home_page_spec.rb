require 'spec_helper'

describe "HomePage" do
  before do
    create_approved_beta_signup('joe@citizen.org')
    @user = User.create!(:email => 'joe@citizen.org', :password => 'random', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
    @user.confirm!
  end
  
  describe "GET /" do
    context "when not logged in" do
      context "when signing up for the beta" do
        before do
          BetaSignup.destroy_all
          ActionMailer::Base.deliveries = []
        end
        
        it "should let a user sign up for the beta by providing their email address" do
          visit root_path
          page.should have_content("Navigating government just got easier.")
          fill_in 'Email', :with => 'joe@citizen.org'
          click_button "Sign up"
          BetaSignup.find_by_email('joe@citizen.org').should_not be_nil
        end
      end
      
      context "when the user views a static page" do
        it "should serve the terms of service" do
            visit terms_of_service_path
            page.should have_content "Terms of Service"
        end
        
        it "should serve the privacy policy" do
            visit privacy_policy_path
            page.should have_content "Privacy Policy"
        end
      end
    end
    
    context "when already logged in" do
      before do
        create_logged_in_user(@user)
      end
      
      it "should show the user the dashboard" do
        visit root_path
        page.should have_content "MyGovBeta"
        click_link 'Joe Citizen'
        page.should have_content 'Your Profile'
        page.should have_content 'First name'
      end
      
      context "when the user does not have a first, last or any other name" do
        before do
          @user.update_attributes(:name => nil)
        end
        
        it "should link to the profile page with 'Your Profile'" do
          visit root_path
          page.should have_content "Your profile"
          click_link "Your profile"
          page.should have_content "Your profile"
          page.should have_content "First name"
        end
      end
      
      context "when the user does not have tasks or local info" do
        before do
          @user.tasks.destroy_all
        end
        
        it "should not show sidebar tabs or dashboard sections for tasks or info" do
          visit root_path
          page.should have_no_content "Tasks"
          page.should have_no_content "Info"
          page.should have_no_content "Your Local Government"
        end
      end
      
      context "when the user has tasks with task items" do
        before do
          @app = App.create!(:name => 'Change your name'){|app| app.redirect_uri = "http://localhost:3000/"}
          @user.tasks.create!(:name => 'Change your name', :app_id => @app.id)
          @user.tasks.first.task_items.create!(:name => 'Get Married!')
          @user.tasks.first.task_items.create!(:name => 'Get Divorced!')
        end
        
        it "should show the tasks on the dashboard" do
          visit root_path
          page.should have_content "MyGovBeta"
          page.should have_content "Tasks"
          page.should have_content "Change your name"
        end
      end
      
      context "when the user has local information" do
        before do
          local_info = JSON.parse(File.read(Rails.root.to_s + "/spec/fixtures/local_info.json"))
          User.any_instance.stub(:local_info).and_return local_info
        end
        
        it "should show local info in the sidebar and in the dashboard" do
          visit root_path
          page.should have_content "Info"
          page.should have_content "Your Local Government"
        end
      end
                
      context "when the user visits the page the first time" do
        before do
          reset_session!
          ApplicationController.any_instance.stub(:rand).with(2).and_return 0
        end
        
        it "should set the GA custom var for the segment" do
          visit root_path
          page.should have_content "_gaq.push(['_setCustomVar',1,'Segment','A', 2]);"
        end
      end
      
      context "when revisiting the page a second and third time" do
        before do
          reset_session!
          ApplicationController.any_instance.stub(:rand).with(2).and_return 0
        end
        
        it "should assign the GA custom var for the segment and always return the same value for subsequent requests for that session" do
          5.times do
            visit root_path
            page.should have_content "_gaq.push(['_setCustomVar',1,'Segment','A', 2]);"
          end
        end
      end
    
      context "when deleting their account" do
        before do
          @mail_size = ActionMailer::Base.deliveries.size
        end
        
        it "should log out the user and destroy the account" do
          visit root_path
          click_link "Delete"
          page.should have_content "Sign in"
          User.find_by_email('joe@citizen.org').should be_nil
          ActionMailer::Base.deliveries.size.should == @mail_size + 1
          ActionMailer::Base.deliveries.last.subject.should == "Your MyGov account has been deleted."
        end
      end
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
end
