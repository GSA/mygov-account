require 'spec_helper'
# To test timeout periods, devise User.timeout_in has be set to three seconds while in test environment
describe "auto_logout" do
  context "User is logged in" do
    before do
      @inactivity_warning_text = "We noticed you haven't been very active in MyUSA"
      Devise.setup do |config|
        config.timeout_in = 3
      end
      
      Rails.application.config.session_timeout_warning_seconds = 1
      create_approved_beta_signup('joe@citizen.org')
      @user = User.create!(:email => 'joe@citizen.org', :password => 'random')
      @user.profile = Profile.new(:first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen', :is_student => true)
      @user.confirm!
      visit(sign_in_path)
      fill_in 'user_email', :with => @user.email
      fill_in 'user_password', :with => @user.password
      click_button 'Sign in'  
    end
  
    describe "test auto warn of imminent logout" do
      it "should have a meta tag to refresh the page when user nears session timeout" do
        visit(root_path)
        page.should have_timeout_warning_metatag
      end

      it "should not display imminent timeout warning when user navigates to page" do
        visit(dashboard_path)
        page.should_not have_content(@inactivity_warning_text)
        page.should have_timeout_warning_metatag
      end

      it "should display warning when page auto refreshes to check remaining session time and then confirm user is logged out" do
        visit(dashboard_path(no_keep_alive: 1))
        page.should_not have_content(@inactivity_warning_text)
        sleep(2)
        visit(dashboard_path(no_keep_alive: 1))
        page.should have_content(@inactivity_warning_text)
        # Make sure that after warning, page will redirect to inactivity timeout
        page.should have_xpath("//meta[@http-equiv=\"refresh\"]")
        sleep(1)
        visit(dashboard_path)
        page.should have_content("Your session expired. Please sign in again.")
      end
    end
  end


  context "User is not logged in" do
    describe "test auto warn of imminent logout" do
      it "should not have redirect" do
        visit(sign_in_path)
        page.should_not have_timeout_warning_metatag
      end
    end
  end
end
