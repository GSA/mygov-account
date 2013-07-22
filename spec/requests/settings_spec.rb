require 'spec_helper'

describe "SettingsPage" do
  before do
    create_approved_beta_signup('joe@citizen.org')
    @user = User.create!(:email => 'joe@citizen.org', :password => 'Password1')
    @user.confirm!
  end

  describe "GET /settings" do
    context "when the user is logged in" do
      before do
        create_logged_in_user(@user)
      end

      it "should show the user a link to change their email address" do
        visit settings_path
        page.should have_content("Change email address")
      end
    end
  end

  describe "GET /user/edit.:id" do
    context "when the user is logged in" do
      before do
        create_logged_in_user(@user)
      end

      it "should show the user a form with their current email address filled in" do
        visit edit_user_registration_path(@user)
        email_field = find_field('Email')
        email_field[:value].should == 'joe@citizen.org'
      end
    end
  end
end
