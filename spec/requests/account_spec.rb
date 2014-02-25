require 'spec_helper'

describe "Account" do
  before do
    @user = create_confirmed_user
  end

  describe "GET /account" do
    context "when the user is logged in" do
      before do
        login(@user)
        @mail_size = ActionMailer::Base.deliveries.size
      end

      it "should show the user links to various account options" do
        visit account_index_path
        page.should have_content "Edit your profile"
        page.should have_content "Change your email address"
        page.should have_content "Change your password"
        page.should have_content "Other networks"
        page.should have_content "Delete your account"
      end


      it "should allow the user to delete their account" do
        visit account_index_path
        click_link "Delete"
        page.should have_content "Your MyUSA account has been deleted"
        page.should have_content "Sign up"
        User.find_by_email('joe@citizen.org').should be_nil
        ActionMailer::Base.deliveries.size.should == @mail_size + 1
        ActionMailer::Base.deliveries.last.subject.should == "Your MyUSA account has been deleted"
      end
    end
  end

  describe "GET /user/edit" do
    context "when the user is logged in" do
      before {login(@user)}

      it "should allow password change" do
        visit account_index_path(@user)
        click_link 'Change your password'
        fill_in('user_password', :with => 'asdf')      # Fill in with invalid input to test validation
        click_button('Change my password')
        page.should have_content("Password must include at least one lower case letter, one upper case letter and one digit.")
        page.should have_content("Password is too short (minimum is 8 characters)")
        new_password = get_random_password
        fill_in('user_password', :with => new_password) # Use valid password, different from create_confirmed_user pasword
        fill_in('user_password_confirmation', :with => new_password)
        click_button('Change my password')
        page.should have_content("Your password was sucessfully updated.")
        click_link 'Sign out'                           # Sign out and sign back in
        fill_in 'Email', :with => 'joe@citizen.org'
        fill_in 'Password', :with => new_password
        click_button 'Sign in'
        current_path.should match('dashboard')
      end

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
        @user.unconfirmed_email.should eq 'jack@citizen.org'
        email = ActionMailer::Base.deliveries.last
        email.to.should eq ['jack@citizen.org']
        email.from.should eq [Mail::Address.new(DEFAULT_FROM_EMAIL).address]
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
        page.should_not have_content('Email is invalid')
      end

      context "when the user changes their email address" do
        it "should change their beta invite address once they have confirmed the new one" do
          visit edit_user_registration_path(@user)
          fill_in('Email', :with => 'jack@citizen.org')
          fill_in('Current password', :with => 'Password1')
          click_button('Update')
          BetaSignup.where(:email => 'jack@citizen.org').count.should eq 0
          BetaSignup.where(:email => 'joe@citizen.org').count.should eq 1
          @user.reload
          @user.confirm!
          BetaSignup.where(:email => 'jack@citizen.org').count.should eq 1
          BetaSignup.where(:email => 'joe@citizen.org').count.should eq 0
        end
      end
    end
  end
end