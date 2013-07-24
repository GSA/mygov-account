require 'spec_helper'

describe "SettingsPage" do
  before do
    @beta_signup = create_approved_beta_signup('joe@citizen.org')
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

      it "should let the user change their email address" do
        visit edit_user_registration_path(@user)
        fill_in('Email', :with => 'joseph@citizen.org')
        fill_in('Current password', :with => 'Password1')
        click_button('Update')
        page.should have_no_content('your account hasn\'t been approved yet')

        @user.reload
        @user.unconfirmed_email.should == 'joseph@citizen.org'
      end

      context "when the user changes their email address" do
        it "should change their beta invite address once they have confirmed the new one" do
          visit edit_user_registration_path(@user)
          fill_in('Email', :with => 'joseph@citizen.org')
          fill_in('Current password', :with => 'Password1')
          click_button('Update')
          BetaSignup.where(:email => 'joseph@citizen.org').count.should == 0
          BetaSignup.where(:email => 'joe@citizen.org').count.should == 1

          @user.reload
          @user.confirm!

          BetaSignup.where(:email => 'joseph@citizen.org').count.should == 1
          BetaSignup.where(:email => 'joe@citizen.org').count.should == 0
        end
      end
    end
  end
end
