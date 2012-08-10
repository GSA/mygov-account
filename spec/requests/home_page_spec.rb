require 'spec_helper'

describe "HomePage" do
  before do
    @user = User.create!(:email => 'joe@citizen.org', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
  end
  
  describe "GET /" do
    
    context "when not logged in" do
      it "should prompt the user to login" do
        visit root_path
        page.should have_content("Sign in with Google")
      end
    end
    
    context "when already logged in" do
      before do
        create_logged_in_user(@user)
      end
      
      it "should greet the user and provide a link to view their profile" do
        visit root_path
        page.should have_content "Hello, Joe Citizen!"
        page.should have_content "View your MyGov Profile"
      end
    end
  end
end
