require 'spec_helper'

describe "Authentications" do
  before do
    @user = create_confirmed_user_with_profile
    login(@user)
  end

  describe "adding a new authentication" do
    context "when the user does not have a google authentication" do
      before { @user.authentications.each {|auth| auth.destroy} }

      it 'allows the user to connect to google' do
        visit root_path
        click_link 'Account'
        click_link 'Other networks'
        click_link 'Add an authentication provider to your account'
        click_link 'Google'
        expect(page).to have_content 'Google'
        visit user_omniauth_authorize_path(:provider => :google)
        page.should have_content "Successfully authenticated from Google account"
        current_path.should eq authentications_path
      end
    end

    context "when another user has a google authentication with the same account" do
      before do
        @user.authentications.create(:provider => "google", :uid => '12345')
        logout
        @user2 = create_confirmed_user_with_profile(email: 'jane@citizen.org')
        @user2.authentications.each {|auth| auth.destroy}
        login(@user2)
      end

      it 'displays an error message when adding google authentication from another account' do
        visit root_path
        click_link 'Account'
        click_link 'Other networks'
        click_link 'Add an authentication provider to your account'
        click_link 'Google'
        page.should have_content "This external account is already linked to another MyUSA account"
        current_path.should eq authentications_path
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
        click_link 'Account'
        click_link 'Other networks'
        page.should have_content 'Google'
        click_link 'Delete'
        current_path.should eq authentications_path
        page.should_not have_content 'Google'
        click_link 'Sign out'
        visit sign_in_path
        click_link 'Sign in with Google'
        current_path.should eq sign_in_path
        expect(page).to have_content "I'm sorry, your account hasn't been approved yet."
      end
    end
  end

  describe "attempting to log in from Google" do
    context "when the user does not have a google authentication but has an account with the same email" do
      before do
        create_confirmed_user_with_profile(email: 'joe.citizen@gmail.com')
        logout
      end

      it "provides a proper message explaining that the corresponding account doesn't allow Google authentication" do
        visit sign_in_path
        click_link 'Sign in with Google'
        current_path.should eq sign_in_path
        expect(page).to have_content "There is another MyUSA account with that email. Please sign in with the service you used to create the account. You can also reset your password."
        expect(page).to have_link("reset your password", href: new_user_password_path)
      end
    end
  end
end
