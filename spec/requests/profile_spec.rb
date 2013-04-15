require 'spec_helper'

describe "Profile" do
  before do
    create_approved_beta_signup('joe@citizen.org')
    @user = User.create!(:email => 'joe@citizen.org', :password => 'random')
    @user.confirm!
  end

  describe "GET /profile" do    
    context "when visiting the web site via a browser" do
      context "when logged in" do
        before do
          create_logged_in_user(@user)
        end

        it "should show a user their profile" do
          visit profile_path
          page.should have_content "Your Profile"
          page.should have_content "Coming soon!"
        end      
      end
    end
  end
end