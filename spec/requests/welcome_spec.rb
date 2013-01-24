require 'spec_helper'

describe "Welcome" do
  before do
    create_approved_beta_signup('joe@citizen.org')
    @user = User.create(:email => 'joe@citizen.org', :password => 'password')
    @user.confirm!
    create_logged_in_user(@user)
    stub_request(:get, "http://api.democracymap.org/geowebdns/endpoints?format=json&fullstack=true&location=12345").
             with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
             to_return(:status => 200, :body => "", :headers => {})
  end
  
  describe "welcome info" do
    it "should collect basic information from the user" do
      visit welcome_path
      page.should have_content 'Paperwork Reduction Act Statement'
      fill_in 'Zip code', :with => '12345'
      click_button 'Continue'
      page.should have_content "MyGovBeta"
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
      page.should have_content 'Paperwork Reduction Act Statement'
      check 'Married'
      check 'Parent'
      click_button 'Continue'
      page.should have_content 'MyGovBeta'
      @user.reload
      @user.marital_status.should == "Married"
      @user.is_parent.should == true
      @user.is_veteran.should be_nil
    end
  end
end