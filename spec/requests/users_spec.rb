require 'spec_helper'

describe "Users" do
  describe "sign up process" do
    context "when a user is not in the beta signup list" do
      it "should not let the user create an account" do
        visit sign_up_path
        fill_in 'Email', :with => 'joe@citizen.org'
        fill_in 'Password', :with => 'password'
        fill_in 'Password confirmation', :with => 'password'
        check 'I agree to the MyGov Terms of Service and Privacy Policy'
        click_button 'Sign up'
        page.should have_content "I'm sorry, your account hasn't been approved yet."
      end
      
      it "should not let the user create an approved beta signup record by manipulating the post" do
        test_email = 'shady@citizen.org'
        visit sign_up_path
        begin
          post beta_signups_path, 'beta_signup' => { 'email' => test_email, 'is_approved' => '1' }
        rescue ActiveModel::MassAssignmentSecurity::Error
          nil
        end
        BetaSignup.where(email: test_email, is_approved: true).first.should eq nil
      end
    end
    
    context "when a user is in the beta signup list" do
      before do
        BetaSignup.create!(:email => 'joe@citizen.org')
      end
      
      context "when as user has not been approved" do
        it "should not let the user create an account" do
          visit sign_up_path
          fill_in 'Email', :with => 'joe@citizen.org'
          fill_in 'Password', :with => 'password'
          fill_in 'Password confirmation', :with => 'password'
          check 'I agree to the MyGov Terms of Service and Privacy Policy'
          click_button 'Sign up'
          page.should have_content "I'm sorry, your account hasn't been approved yet."
        end
      end
    
      context "when a user has been approved" do
        before do
          BetaSignup.find_by_email('joe@citizen.org').update_attribute(:is_approved, true)
        end
        
        context "when the user does not accept the terms of serivce and privacy policy" do
          it "should not register the user and display an error message" do
            visit sign_up_path
            fill_in 'Email', :with => 'joe@citizen.org'
            fill_in 'Password', :with => 'password'
            fill_in 'Password confirmation', :with => 'password'
            click_button 'Sign up'
            page.should have_content "Please read and accept the MyGov Terms of Service and Privacy Policy."
          end
        end
        
        it "should let the user create an account" do
          visit sign_up_path
          fill_in 'Email', :with => 'joe@citizen.org'
          fill_in 'Password', :with => 'password'
          fill_in 'Password confirmation', :with => 'password'
          check 'I agree to the MyGov Terms of Service and Privacy Policy'
          click_button 'Sign up'
          page.should have_content 'Thank you for signing up'
          ActionMailer::Base.deliveries.last.to.should == ['joe@citizen.org']
          ActionMailer::Base.deliveries.last.from.should == ["no-reply@my.usa.gov"]
        end
    
        context "when a user has signed up, and confirms their email address" do
          it "should collect some basic information from the user in welcoming them to MyGov" do
            visit sign_up_path
            fill_in 'Email', :with => 'joe@citizen.org'
            fill_in 'Password', :with => 'password'
            fill_in 'Password confirmation', :with => 'password'
            check 'I agree to the MyGov Terms of Service and Privacy Policy'
            click_button 'Sign up'
            page.should have_content 'Thank you for signing up'

            user = User.find_by_email('joe@citizen.org')
            visit user_confirmation_path(:confirmation_token => user.confirmation_token)
            page.should have_content "Tell us more about yourself."
          end
        end
        
        context "when a user signs up via a third party" do
          it "should welcome them to MyGov and prompt them for more information" do
            visit sign_up_path
            click_link 'Sign in with Google'
            page.should have_content "Tell us more about yourself"
          end
        end
      end
    end
  end
end