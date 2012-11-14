require 'spec_helper'

describe "Welcome" do
  before do
    BetaSignup.create!(:email => 'joe@citizen.org', :is_approved => true)
    @user = User.create(:email => 'joe@citizen.org', :password => 'password')
    @user.confirm!
    create_logged_in_user(@user)
  end
  
  describe "welcome info" do
    it "should collect basic information from the user" do
      visit welcome_path
      fill_in 'Zip code', :with => '12345'
      click_button 'Continue'
      page.should have_content "MyGov Dashboard"
      @user.reload
      @user.zip.should == "12345"
      visit profile_path
      page.should have_content "12345"
    end
    
    context "when a user enters a bad zip code" do
      it "should display an error message" do
        visit welcome_path
        fill_in 'Zip code', :with => '1234'
        click_button 'Continue'
        page.should have_content "Please enter your 5 digit zip code."
      end
    end
  end
  
  describe "welcome about you" do
    it "should collect information about you" do
      visit welcome_path(:step => 'about_you')
      check 'Married'
      check 'Parent'
      click_button 'Continue'
      page.should have_content 'MyGov Dashboard'
      @user.reload
      @user.marital_status.should == "Married"
      @user.is_parent.should == true
      @user.is_veteran.should be_nil
    end
  end

end