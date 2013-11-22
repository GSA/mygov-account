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
          page.should have_content("Take control of how you interact with government.")
          fill_in 'Email', :with => ''
          click_button "Sign up"
          page.should_not have_content("Thanks for signing up")
          page.should have_content("Email can't be blank")
        end
        
        it "should let a user sign up for the beta by providing their email address" do
          visit root_path
          page.should have_content("Take control of how you interact with government.")
          fill_in 'Email', :with => 'joe@citizen.org'
          click_button "Sign up"
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
    
    context "when already logged in" do
      before {login(@user)}
      
      it "should show the user the dashboard" do
        visit root_path
        page.should have_content "MyUSA"
        click_link 'Joe Citizen'
        page.should have_content 'Your Profile'
        page.should have_content 'First name'
      end
      
      it "should provide a link to the app gallery" do
        visit root_path
        page.should have_link "App Gallery", :href => apps_path
      end
      
      context "when the user does not have a first, last or any other name" do
        before do
          @user.profile.update_attributes(:first_name => nil, :last_name => nil)
        end
                
        it "should link to the profile page with 'Your profile'" do
          visit root_path
          page.should have_content "Your profile"
          click_link "Your profile"
          page.should have_content "Your profile"
          page.should have_content "First name"
        end
      end
      
      context "when the user does not have tasks" do
        before { @user.tasks.destroy_all }
        
        it "should not show sidebar tabs or dashboard sections for tasks or info" do
          visit root_path
          page.should have_no_content "Tasks"
          page.should have_content "Info"
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
        before {@mail_size = ActionMailer::Base.deliveries.size}
        
        it "should log out the user and destroy the account" do
          visit root_path
          click_link "Delete"
          page.should have_content "Your MyUSA account has been deleted"
          page.should have_content "Sign up"
          User.find_by_email('joe@citizen.org').should be_nil
          ActionMailer::Base.deliveries.size.should == @mail_size + 1
          ActionMailer::Base.deliveries.last.subject.should == "Your MyUSA account has been deleted"
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
  
  describe "GET /discovery" do
    context "when not logged in" do
      it "should forward to a login page" do
        visit discovery_path
        page.should have_content "Please sign in or sign up before continuing"
      end
    end
    
    context "when logged in" do
      before {login(@user)}
      
      it "should show the discovery page" do
        visit discovery_path
        page.should have_content "Discovery Bar"
      end
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
