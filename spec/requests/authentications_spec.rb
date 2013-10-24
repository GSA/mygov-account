require 'spec_helper'

describe "Authentications" do
  before do
    create_confirmed_user_with_profile; login(@user)
  end

  describe "adding a new authentication" do
    context "when the user does not have a google authentication" do
      before { @user.authentications.each {|auth| auth.destroy} }

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
        @user.authentications.create(:provider => "google", :uid => 'joe.citizen@gmail.com')
      end

      it 'allows the user to delete their authentication which disables login with that provider' do
        visit root_path
        click_link 'Settings'
        click_link 'Authentication providers'
        page.should have_content 'Google'
        click_link 'Delete'
        page.should_not have_content 'Google'
        click_link 'Logout'
        visit sign_in_path
        click_link 'Sign in with Google'
        expect(page).to have_content "I'm sorry, your account hasn't been approved yet."
      end
    end
  end
end
