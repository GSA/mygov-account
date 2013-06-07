require 'spec_helper'

describe "Authentications" do
  before do
    create_approved_beta_signup('joe@citizen.org')
    @user = User.create!(:email => 'joe@citizen.org', :password => 'Password1')
    @user.confirm!
    create_logged_in_user(@user)
  end
  
  describe "adding a new authentication" do
    context "when the user does not have any additional authentication providers" do
      it "should allow the user to connect their MAX.gov account" do
        visit root_path
        click_link 'Settings'
        click_link 'Authentication providers'
        click_link 'Add an authentication provider to your account'
        click_link 'Connect your MAX.gov account'
        page.should have_content 'max.gov'
      end
    end
  end
  
  describe "deleting an authentication" do
    context "when the user has an authentication" do
      before do
        @user.authentications.create(:provider => "max.gov", :uid => 'joe.citizen@usa.gov')
      end
      
      it "should allow the user to delete their authentication, which should disable login with that provider" do
        visit root_path
        click_link 'Settings'
        click_link 'Authentication providers'
        page.should have_content 'max.gov'
        click_link 'Delete'
        page.should_not have_content 'max.gov'
        click_link 'Sign out'
        visit sign_in_path
        click_link 'More sign in options'
        click_link 'Sign in with MAX.gov'
        page.should have_content "I'm sorry, we don't have an account associated with your MAX.gov account."
      end
    end
  end
end
