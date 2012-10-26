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
          page.should have_content("We're getting ready to launch the MyGov private beta. Sign up to kick the tires")
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
      
      context "when the user has tasks with task items" do
        before do
          @app = App.create!(:name => 'Change your name', :action_phrase => 'changing your name'){|app| app.redirect_uri = "http://localhost:3000/"}
          @user.tasks.create!(:name => 'Change your name', :app_id => @app.id)
          @user.tasks.first.task_items.create!(:name => 'Get Married!')
          @user.tasks.first.task_items.create!(:name => 'Get Divorced!')
        end
        
        it "should show the tasks on the dashboard and allow the user to remove tasks" do
          visit root_path
          page.should have_content "MyGovBeta"
          page.should have_content "Get Married!"
          page.should have_content "Get Divorced!"
          page.should have_link "Remove"
        end
      end
    
      context "when it is a US Holiday" do
        before do
          UsHoliday.create!(:name => "Pretend US Holiday", :observed_on => Date.current, :uid => 'pretend-us-holiday')
        end
        
        it "should show a US holiday notice on the dashboard sidebar" do
          visit root_path
          page.should have_content "Today is Pretend US Holiday"
        end
      end
      
      context "when historical events occured on that day in the past" do
        before do
          UsHistoricalEvent.create!(:summary => 'Pretend Historical Event', :uid => 'pretend-historical-event', :day => Date.current.day, :month => Date.current.month, :description => 'Something historical happened today.')
        end
        
        it "should show the event summary and description on the dashboard sidebar" do
          visit root_path
          page.should have_content "Pretend Historical Event - Something historical happened today."
        end
      end
      
      context "when the user has a zip code in their profile" do
        before do
          @user.update_attributes(:zip => '21209')
        end
        
        context "when the UV Index for the user's profile is available" do
          before do
            epa_response = [{"UV_INDEX" => 11, "ZIP_CODE" => 21209, "UV_ALERT" => 0}]
            EpaUvIndex::Client.should_receive(:daily_for).with(:zip => @user.zip).and_return epa_response
          end
        
          it "should display the UV index on the dashboard" do
            visit root_path
            page.should have_content "Your current UV index is: 11"
          end
        end
      end
      
      context "when the user does not have a zip code" do
        it "should not check for the UV index" do
          EpaUvIndex::Client.should_not_receive(:daily_for)
          visit root_path
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
        it "should log out the user and destroy the account" do
          visit root_path
          click_link "Delete"
          page.should have_content "Sign in"
          User.find_by_email('joe@citizen.org').should be_nil
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
      page.should have_content "MyGov terms of service"
    end
  end
end