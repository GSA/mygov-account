require 'spec_helper'

describe "Users" do
  describe "sign in links" do
    context "when a user is not signed in" do
      it "should have a sign-in link" do
        visit sign_up_path
        page.should have_content "Already using MyUSA?"
        page.should have_content "Sign in"
        click_link "Sign in"
        current_path.should == sign_in_path

        visit root_path
        page.should have_content "Already using MyUSA?"
        page.should have_content "Sign in"
        click_link "Sign in"
        current_path.should == sign_in_path
      end

      it "should link to third party sign ins" do
        visit sign_in_path
        page.should have_link 'Sign in with Google'
        page.should have_link 'Sign in with VeriSign'
      end

      it "should not have a sign-in link on the sign-in page" do
        visit sign_in_path
        page.should_not have_content "Already using MyUSA?"
      end
    end

    context "when a user is signed in" do
      before {create_confirmed_user; login(@user)}

      it "should not ask the user to sign in" do
        visit dashboard_path
        page.should_not have_content "Already using MyUSA?"
        page.should_not have_content "Sign in"
      end
    end
  end

  describe "sign up process" do
    it "should provide links to third party sign in services" do
      visit sign_up_path
      page.should have_link 'Sign up with Google'
      page.should have_link 'Sign up with VeriSign'
    end

    context "when a user is not in the beta signup list" do
      it "should not let the user create an account" do
        visit sign_up_path
        fill_in_email_and_password
        check 'I agree to the MyUSA Terms of Service and Privacy Policy'
        click_button 'Sign up'
        page.should have_content "I'm sorry, your account hasn't been approved yet."
      end

      it "should not let the user create an approved beta signup record by passing in is_approved to the post request" do
        test_email = 'shady@citizen.org'
        begin
          post "beta_signups", 'beta_signup' => { 'email' => test_email, 'is_approved' => '1' }
        rescue ActiveModel::MassAssignmentSecurity::Error
          nil
        end
        BetaSignup.where(email: test_email, is_approved: true).first.should eq nil
      end

      it "should not let the user create an approved beta signup record by manipulating the email address" do
        test_email = "shady@citizen.org"
        visit root_path
        fill_in 'Email', :with => test_email + "&is_approved=1"
        click_button 'Sign up'
        BetaSignup.find_by_email(test_email).should be_nil
        BetaSignup.find_by_email(test_email + "&is_approved=1").should be_nil
      end
    end

    context "when a user is in the beta signup list" do
      before { BetaSignup.create!(:email => 'joe@citizen.org') }

      context "when a user has not been approved" do
        it "should not let the user create an account" do
          visit sign_up_path
          fill_in_email_and_password
          check 'I agree to the MyUSA Terms of Service and Privacy Policy'
          click_button 'Sign up'
          page.should have_content "I'm sorry, your account hasn't been approved yet."
        end
      end

      context "when a user has been approved" do
        before { BetaSignup.find_by_email('joe@citizen.org').update_attribute(:is_approved, true) }

        context "when the user does not accept the terms of serivce and privacy policy" do
          context "when the user fills in everything else" do
            it "should not register the user and display an error message" do
              visit sign_up_path
              fill_in_email_and_password
              click_button 'Sign up'
              page.should have_content "Terms of service must be accepted"
            end
          end

          context "when the user doesn't fill in everything else" do
            it "should display error messages for all the missing bits of information" do
              visit sign_up_path
              click_button 'Sign up'
              page.should have_content "Email can't be blank"
              page.should have_content "Terms of service must be accepted"
            end
          end
        end

        context "when no user exists with the supplied email address" do
          before do
            user = User.find_by_email('joe@citizen.org')
            user.destroy if user
          end

          it "should let the user create an account" do
            visit sign_up_path
            fill_in_email_and_password
            check 'I agree to the MyUSA Terms of Service and Privacy Policy'
            click_button 'Sign up'
            page.should have_content 'Thank you for signing up'
            ActionMailer::Base.deliveries.last.to.should == ['joe@citizen.org']
            ActionMailer::Base.deliveries.last.from.should == ["projectmyusa@gsa.gov"]
          end

          context "when the user submits a password that has less than 8 characters" do
            it "should not create the user account" do
              visit sign_up_path
              fill_in_email_and_password(password:'badpass')
              check 'I agree to the MyUSA Terms of Service and Privacy Policy'
              click_button 'Sign up'
              page.should have_content 'Password is too short (minimum is 8 characters)'
            end
          end

          context "when the user submits a password that isn't sufficiently strong" do
            it "should not create the user account" do
              visit sign_up_path
              fill_in_email_and_password(password:'password')
              check 'I agree to the MyUSA Terms of Service and Privacy Policy'
              click_button 'Sign up'
              page.should have_content 'must include at least one lower case letter, one upper case letter and one digit.'
            end
          end

          context "when the user submits a password with special characters" do
            it "should create an account" do
              visit sign_up_path
              fill_in_email_and_password(email:'joe@citizen.org', password:'Password!2')
              check 'I agree to the MyUSA Terms of Service and Privacy Policy'
              click_button 'Sign up'
              page.should have_content 'Thank you for signing up'
            end
          end
        end

        context "when a third-party user exists with the same email but a different uid and provider" do
          before do
            user = User.new(:email => 'joe@citizen.org', :password => 'Password1')
            user.authentications.new(:provider => 'other_provider', :uid => 'joe@citizen.org')
            user.save!
          end

          it "should not allow a new user to be created or login with that email address" do
            visit sign_up_path
            fill_in_email_and_password
            check 'I agree to the MyUSA Terms of Service and Privacy Policy'
            click_button 'Sign up'
            page.should have_content 'Email has already been taken'
          end
        end

        context "when a local user exists with the same email" do
          before do
            create_confirmed_user('joe.citizen@gmail.com')
          end

          it "should not let someone sign in with a third party service that identifies the user with the same email" do
            visit sign_in_path
            click_link 'Sign in with Google'
            page.should have_content 'We already have an account with that email. Make sure login with the service you used to create the account.'
          end
        end

        it "should set the user's name" do
          visit sign_up_path
          fill_in_email_and_password
          fill_in 'First name', :with => 'Joe'
          fill_in 'Last name', :with => 'Citizen'
          check 'I agree to the MyUSA Terms of Service and Privacy Policy'
          click_button 'Sign up'
          page.should have_content 'Thank you for signing up'
          ActionMailer::Base.deliveries.last.to.should == ['joe@citizen.org']
          ActionMailer::Base.deliveries.last.from.should == ["projectmyusa@gsa.gov"]
          User.find_by_email('joe@citizen.org').profile.name.should == 'Joe Citizen'
        end
      end
    end
  end

  describe "sign in process" do
    before {create_confirmed_user}

    it "should lock the account if the user fails to login five times" do
      visit sign_in_path
      lock_account
      page.should have_content "Your account is locked."
      @user.reload
      @user.unlock_token.should_not be_nil
      ActionMailer::Base.deliveries.last.to.should == ['joe@citizen.org']
      ActionMailer::Base.deliveries.last.subject.should == 'Unlock Instructions'
    end
  end

  describe "sign out process" do
    before {create_confirmed_user_with_profile; login(@user)}

    it "should redirect the user to the sign in page" do
      visit dashboard_path
      click_link 'Logout'
      page.should have_content "Sign in"
      page.should have_content "Didn't receive confirmation instructions?"
    end
  end

  describe "change your name" do
    before {create_confirmed_user_with_profile; login(@user)}

    it "should change the user's name when first or last name changes" do
      visit edit_profile_path
      fill_in 'First name', :with => 'Jane'
      click_button 'Update profile'
      page.should have_content "Logout"
      page.should have_content "Edit profile"
      page.should_not have_content "Joe"
      page.should have_content "Jane"
    end
  end

  describe "change your password" do
    before {create_confirmed_user}

    it "changes the user's password and sends notification and confirmation emails" do
      visit sign_in_path
      click_link "Forgot your password?"
      fill_in 'user_email', :with => 'joe@citizen.org'
      click_button "Email password reset instructions"

      expect(ActionMailer::Base.deliveries.last.subject).to eq('Reset password instructions')

      @user.reload

      expect(@user.reset_password_token.blank?).to be false

      visit edit_user_password_path(reset_password_token: @user.reset_password_token)
      fill_in 'user_password', :with => 'Secure_passw0rd'
      fill_in 'user_password_confirmation', :with => 'Secure_passw0rd'
      click_button "Change my password"

      expect(ActionMailer::Base.deliveries.last.subject).to eq('Your MyUSA password has been changed')
    end
  end

  describe "login, confirmation, and unlock messages" do
    before { create_confirmed_user }

    it "yields the same message irregardless of the email's existence in the db for login attempts" do
      visit sign_in_path
      fill_in 'user_email', with: 'joe@citizen.org'
      click_button "Sign in"
      alert_message = find('div.alert-danger').text.squish

      fill_in 'user_email', with: 'joe_schmoe@citizen.org'
      click_button "Sign in"

      expect(find('div.alert-danger').text.squish).to eq alert_message
    end

    it "yields the same message irregardless of the email's existence in the db when submitting to the password reset form" do
      visit new_user_password_path
      fill_in 'user_email', with: 'joe@citizen.org'
      click_button "Email password reset instructions"
      alert_message = find('div.alert-info').text.squish

      fill_in 'user_email', with: 'joe_schmoe@citizen.org'
      click_button "Email password reset instructions"

      expect(find('div.alert-info').text.squish).to eq alert_message
    end

    it "yields the same message irregardless of the email's existence in the db when submitting to the confirmation instructions form" do
      visit new_user_confirmation_path
      fill_in 'user_email', with: 'joe@citizen.org'
      click_button "Send"
      alert_message = find('div.alert').text.squish

      fill_in 'user_email', with: 'joe_schmoe@citizen.org'
      click_button "Send"

      expect(find('div.alert').text.squish).to eq alert_message
    end

    it "yields the same message irregardless of the email's existence in the db for when submitting to the unlock instructions form" do
      visit new_user_unlock_path
      fill_in 'user_email', with: 'joe@citizen.org'
      click_button "Send"
      alert_message = find('div.alert').text.squish

      fill_in 'user_email', with: 'joe_schmoe@citizen.org'
      click_button "Send"

      expect(find('div.alert').text.squish).to eq alert_message
    end
  end
end
