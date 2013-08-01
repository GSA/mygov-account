require 'spec_helper'

describe "Authentications" do
  before do
    create_approved_beta_signup('joe@citizen.org')
    @user = User.create!(:email => 'joe@citizen.org', :password => 'Password1')
    @user.confirm!
    create_logged_in_user(@user)
  end
  
  describe "adding a new authentication" do
    context "when the user does not have a MAX authentication" do
      it 'allows the user to connect their Max.gov account' do
        visit root_path
        click_link 'Settings'
        click_link 'Authentication providers'
        click_link 'Add an authentication provider to your account'
        click_link 'Connect your MAX.gov account'
        expect(page).to have_content 'Max.Gov'
      end
    end

    context "when the user already has a MAX authentication" do
      before do
        @user.authentications << Authentication.create!(:uid => '12345', :provider => 'max.gov')
      end

      it 'does not allow the user to connect their Max.gov account' do
        visit root_path
        click_link 'Settings'
        click_link 'Authentication providers'
        click_link 'Add an authentication provider to your account'
        expect(page).to_not have_content 'Max.Gov'
      end
    end

    context "when the user does not have a google authentication" do
      before do
        @user.authentications.each {|auth| auth.destroy}
      end

      it 'allows the user to connect to google' do
        visit root_path
        click_link 'Settings'
        click_link 'Authentication providers'
        click_link 'Add an authentication provider to your account'
        expect(page).to have_content 'Google'
      end
    end

  end
  
  describe "deleting an authentication" do
    context "when the user has an authentication" do
      before do
        @user.authentications.create(:provider => "max.gov", :uid => 'joe.citizen@usa.gov')
      end
      
      it 'allows the user to delete their authentication which disables login with that provider' do
        visit root_path
        click_link 'Settings'
        click_link 'Authentication providers'
        page.should have_content 'Max.Gov'
        click_link 'Delete'
        page.should_not have_content 'Max.Gov'
        click_link 'Sign out'
        visit sign_in_path
        click_link 'More sign in options'
        click_link 'Sign in with MAX.gov'
        expect(page).to have_content "I'm sorry, we don't have an account associated with your MAX.gov account."
      end
    end
  end
end
