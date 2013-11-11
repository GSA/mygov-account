require 'spec_helper'

describe "SettingsPage" do
  before {create_confirmed_user}

  describe "GET /settings" do
    context "when the user is logged in" do
      before {login(@user)}

      it "should show the user a link to change their email address" do
        visit settings_path
        page.should have_content("Change email address")
      end
    end
  end

  describe "GET /user/edit" do
    context "when the user is logged in" do
      before {login(@user)}

      it "should show the user a form with their current email address filled in" do
        visit edit_user_registration_path(@user)
        email_field = find_field('Email')
        email_field[:value].should == 'joe@citizen.org'
      end

      it "should let the user change their email address" do
        visit edit_user_registration_path(@user)
        fill_in('Email', :with => 'jack@citizen.org')
        fill_in('Current password', :with => 'Password1')
        click_button('Update')
        page.should have_no_content('your account hasn\'t been approved yet')
        expect(page).to have_content('You updated your account successfully, but we need to verify your new email address.')
        page.body.should =~ /jack/
        page.body.should_not =~ /joe/
        @user.reload
        @user.unconfirmed_email.should == 'jack@citizen.org'
        email = ActionMailer::Base.deliveries.last
        email.to.should == ['jack@citizen.org']
        email.from.should == ["projectmyusa@gsa.gov"]
        expect(email.body).to include('jack@citizen.org')
        expect(email.body).not_to include('joe@citizen.org')
      end

      it "should not allow the user change their email address to an invalid value" do
        visit edit_user_registration_path(@user)
        fill_in('Email', :with => 'chaudet, roy@epa.gov')
        fill_in('Current password', :with => 'Password1')
        click_button('Update')
        # Change the rest of this to the invalid message
        expect(page).to have_no_content('You updated your account successfully, but we need to verify your new email address.')
        page.should have_content('Email does not appear to be valid')
      end

      context "when the user changes their email address" do
        it "should change their beta invite address once they have confirmed the new one" do
          visit edit_user_registration_path(@user)
          fill_in('Email', :with => 'jack@citizen.org')
          fill_in('Current password', :with => 'Password1')
          click_button('Update')
          BetaSignup.where(:email => 'jack@citizen.org').count.should == 0
          BetaSignup.where(:email => 'joe@citizen.org').count.should == 1
          @user.reload
          @user.confirm!
          BetaSignup.where(:email => 'jack@citizen.org').count.should == 1
          BetaSignup.where(:email => 'joe@citizen.org').count.should == 0
        end
      end
    end
  end
end
