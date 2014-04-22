require 'spec_helper'

describe "Users" do
  describe "Didn't receive confirmation link" do
    context "when a user is not signed in" do
      it "should give a proper message if no email is entered" do
        visit new_user_confirmation_path
        fill_in 'Email', with: ''
        click_button 'Send'
        page.should have_content 'Please enter an email address'
      end

      it "should give a proper message if an invalid email is entered" do
        visit new_user_confirmation_path
        fill_in 'Email', with: 'xyz'
        click_button 'Send'
        page.should have_content 'Please enter a valid email address'
      end
    end
  end

  describe "Didn't receive unlock link" do
    context "when a user is not signed in" do
      it "should give a proper message if no email is entered" do
        visit new_user_unlock_path
        fill_in 'Email', with: ''
        click_button 'Send'
        page.should have_content 'Please enter an email address'
      end

      it "should give a proper message if an invalid email is entered" do
        visit new_user_unlock_path
        fill_in 'Email', with: 'xyz'
        click_button 'Send'
        page.should have_content 'Please enter a valid email address'
      end
    end
  end

  describe "Forgot password link" do
    context "when a user is not signed in" do
      it "should give a proper message if no email is entered" do
        visit new_user_password_path
        fill_in 'Email', with: ''
        click_button 'Email password reset instructions'
        page.should have_content 'Please enter an email address'
      end

      it "should give a proper message if an invalid email is entered" do
        visit new_user_password_path
        fill_in 'Email', with: 'xyz'
        click_button 'Email password reset instructions'
        page.should have_content 'Please enter a valid email address'
      end
    end
  end

  describe "sign in links" do
    context "when a user is not signed in" do
      it "should have a sign-in link" do
        visit sign_up_path
        page.should have_content "Already using MyUSA?"
        page.should have_content "Sign in"
        click_link "Sign in"
        current_path.should eq sign_in_path
        page.should_not have_content "Remember me"

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

      it "should not have a beta modal" do
        visit sign_in_path
        page.should_not have_content "MyUSA is currently in limited Beta use. Only Beta testers are currently able to sign up."
      end
    end

    context "when a user is signed in" do
      before {@user = create_confirmed_user; login(@user)}

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
      page.should have_selector("span#tip-password")
    end

    it "should indicate which fields are required and have '* Required'" do
      visit sign_up_path

      page.should have_content "Email *" # Email is a required field
      page.should have_content "Zip"     # Zip is not.
      page.should_not have_content "Zip *"
      page.should have_content "* Required Field"
      page.should have_selector("input[type=email][name='user[email]'][aria-required=true]")
      page.should have_selector("input[type=text][name='user[zip]']")
      page.should_not have_selector("input[type=text][name='user[zip]'][aria-required=true]")
    end

    context "when a user is not in the beta signup list" do
      it "should not let the user create an account" do
        visit sign_up_path
        fill_in_email_and_password
        check 'I agree to the MyUSA Terms of service and Privacy policy'
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
          check 'I agree to the MyUSA Terms of service and Privacy policy'
          click_button 'Sign up'
          page.should have_content "I'm sorry, your account hasn't been approved yet."
        end
      end

      context "when a user has been approved" do
        before { BetaSignup.find_by_email('joe@citizen.org').update_attribute(:is_approved, true) }

        context "when the user does not accept the terms of service and privacy policy" do
          context "when the user fills in everything else" do
            it "should not register the user and display an error message" do
              visit sign_up_path
              page.should have_content "Password *"
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
              page.should have_content "Password *"
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
            check 'I agree to the MyUSA Terms of service and Privacy policy'
            click_button 'Sign up'
            page.should have_content 'Thank you for signing up'
            page.should_not have_content "we&rsquo;ll"
            ActionMailer::Base.deliveries.last.to.should   eq ['joe@citizen.org']
            ActionMailer::Base.deliveries.last.from.should eq [Mail::Address.new(DEFAULT_FROM_EMAIL).address]
            ActionMailer::Base.deliveries.last.should have_content("Welcome to MyUSA!")
            ActionMailer::Base.deliveries.last.should have_content("confirmation?confirmation_token=")
          end

          it "should personalize confirmation message" do
            visit sign_up_path
            fill_in_email_and_password
            fill_in 'user_first_name', :with => 'Joe'
            check 'I agree to the MyUSA Terms of service and Privacy policy'

            click_button 'Sign up'
            page.should have_content 'Thank you for signing up'
            ActionMailer::Base.deliveries.last.to.should eq ['joe@citizen.org']
            ActionMailer::Base.deliveries.last.from.should eq [Mail::Address.new(DEFAULT_FROM_EMAIL).address]
            ActionMailer::Base.deliveries.last.should have_content("Welcome to MyUSA, Joe!")
            email = ActionMailer::Base.deliveries.last
            host_params = ActionMailer::Base.default_url_options
            user = User.find_by_email('joe@citizen.org')
            email.subject.should eq "Confirmation instructions"
            email.body.encoded.should have_link('MyUSA App Gallery', href: apps_url(host_params))
            email.body.raw_source.should have_link('contact us')
            email.body.raw_source.should have_link('link', href: user_confirmation_url(host_params.merge(confirmation_token: user.confirmation_token)))
            email.body.raw_source.should_not have_link('edit your notification settings', href: account_index_url(host_params))
            email.body.raw_source.should have_link('update your profile', href: edit_profile_url(host_params.merge(profile: user.profile)))
            email.body.raw_source.should have_content("confirmation?confirmation_token=#{user.confirmation_token}")
          end

          context "when the user submits a password that has less than 8 characters" do
            it "should not create the user account" do
              visit sign_up_path
              fill_in_email_and_password(password:'badpass')
              check 'I agree to the MyUSA Terms of service and Privacy policy'
              click_button 'Sign up'
              page.should have_content 'Password is too short (minimum is 8 characters)'
            end
          end

          context "when the user submits a password that isn't sufficiently strong" do
            it "should not create the user account" do
              visit sign_up_path
              fill_in_email_and_password(password:'password')
              check 'I agree to the MyUSA Terms of service and Privacy policy'
              click_button 'Sign up'
              page.should have_content 'must include at least one lower case letter, one upper case letter and one digit.'
            end
          end

          context "when the user submits a zip that isn't sufficiently formatted" do
            it "should not create the user account" do
              visit sign_up_path
              fill_in_email_and_password
              fill_in 'Zip', :with => '1234'
              check 'I agree to the MyUSA Terms of service and Privacy policy'
              click_button 'Sign up'
              page.should have_content 'should be in the form 12345'
            end
          end

          context "when the user submits a password with special characters" do
            it "should create an account" do
              visit sign_up_path
              fill_in_email_and_password(email:'joe@citizen.org', password:'Password!2')
              check 'I agree to the MyUSA Terms of service and Privacy policy'
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
            check 'I agree to the MyUSA Terms of service and Privacy policy'
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
            expect(page).to have_content "There is another MyUSA account with that email. Please sign in with the service you used to create the account. You can also reset your password."
            expect(page).to have_link("reset your password", href: new_user_password_path)
          end
        end

        it "should set the user's name" do
          visit sign_up_path
          fill_in_email_and_password
          fill_in 'First name', :with => 'Joe'
          fill_in 'Last name', :with => 'Citizen'
          check 'I agree to the MyUSA Terms of service and Privacy policy'
          click_button 'Sign up'
          page.should have_content 'Thank you for signing up'
          ActionMailer::Base.deliveries.last.to.should eq ['joe@citizen.org']
          ActionMailer::Base.deliveries.last.from.should eq [Mail::Address.new(DEFAULT_FROM_EMAIL).address]
          User.find_by_email('joe@citizen.org').profile.name.should == 'Joe Citizen'
        end

        it "should display a captcha only after the first account" do
          visit sign_up_path
          page.should_not have_css "input[name=recaptcha_response_field]"
          fill_in_email_and_password
          fill_in 'First name', :with => 'Joe'
          fill_in 'Last name', :with => 'Citizen'
          check 'I agree to the MyUSA Terms of service and Privacy policy'
          click_button 'Sign up'
          page.should have_content 'Thank you for signing up'

          visit sign_up_path
          page.should have_css "input[name=recaptcha_response_field]"
        end
      end
    end
  end

  describe "sign in process" do
    before {@user = create_confirmed_user}

    it "should lock the account if the user fails to login five times" do
      visit sign_in_path
      lock_account
      page.should have_content "There are problems with that email address. You will receive an email if your account has been locked. Otherwise, try resetting your password."
      @user.reload
      @user.unlock_token.should_not be_nil
      ActionMailer::Base.deliveries.last.to.should eq ['joe@citizen.org']
      ActionMailer::Base.deliveries.last.subject.should eq 'Unlock Instructions'
    end
  end

  describe "sign out process" do
    before {@user = create_confirmed_user_with_profile; login(@user)}

    it "should redirect the user to the sign in page" do
      visit dashboard_path
      click_link 'Sign out'
      page.should have_content "Sign in"
      page.should have_content "Didn't receive confirmation instructions?"
    end
  end

  describe "change your name" do
    before {@user = create_confirmed_user_with_profile; login(@user)}

    it "should change the user's name when first or last name changes" do
      visit edit_profile_path
      fill_in 'First name', :with => 'Jane'
      click_button 'Update profile'
      page.should have_content "Sign out"
      page.should have_content "Edit your profile"
      page.should have_content "First name: Jane"
    end
  end

  describe "change your password" do
    before {@user = create_confirmed_user}

    it "changes the user's password and sends notification and confirmation emails" do
      visit sign_in_path
      click_link "Forgot your password?"
      fill_in 'Email', :with => 'joe@citizen.org'
      click_button "Email password reset instructions"

      expect(ActionMailer::Base.deliveries.last.subject).to eq('Reset password instructions')

      @user.reload

      expect(@user.reset_password_token.blank?).to be false

      visit edit_user_password_path(reset_password_token: @user.reset_password_token)
      fill_in 'user_password', :with => 'Secure_passw0rd'
      click_button "Change my password"

      expect(ActionMailer::Base.deliveries.last.subject).to eq('Your MyUSA password has been changed')
      page.should have_content("Your password was changed successfully. You are now signed in.")
    end
  end

  describe "login, confirmation, and unlock messages" do
    before { @user = create_confirmed_user }

    it "yields the same message irregardless of the email's existence in the db for login attempts" do
      visit sign_in_path
      fill_in 'user_email', with: 'joe@citizen.org'
      click_button "Sign in"
      alert_message = find('div.alert-box').text.squish

      fill_in 'user_email', with: 'joe_schmoe@citizen.org'
      click_button "Sign in"

      expect(find('div.alert-box').text.squish).to eq alert_message
    end

    it "yields the same message irregardless of the email's existence in the db when submitting to the password reset form" do
      visit new_user_password_path
      fill_in 'user_email', with: 'joe@citizen.org'
      click_button "Email password reset instructions"
      alert_message = find('div.alert-box').text.squish

      fill_in 'user_email', with: 'joe_schmoe@citizen.org'
      click_button "Email password reset instructions"

      expect(find('div.alert-box').text.squish).to eq alert_message
    end

    it "yields the same message regardless of the email's existence in the db when submitting to the confirmation instructions form" do
      visit new_user_confirmation_path
      fill_in 'user_email', with: 'joe@citizen.org'
      click_button "Send"
      alert_message = find('div.alert-box').text.squish

      visit new_user_confirmation_path
      fill_in 'user_email', with: 'joe_schmoe@citizen.org'
      click_button "Send"

      expect(find('div.alert-box').text.squish).to eq alert_message
    end

    it "yields the same message irregardless of the email's existence in the db for when submitting to the unlock instructions form" do
      visit new_user_unlock_path
      fill_in 'user_email', with: 'joe@citizen.org'
      click_button "Send"
      alert_message = find('div.alert-box').text.squish

      visit new_user_unlock_path
      fill_in 'user_email', with: 'joe_schmoe@citizen.org'
      click_button "Send"

      expect(find('div.alert-box').text.squish).to eq alert_message
    end
  end
end
