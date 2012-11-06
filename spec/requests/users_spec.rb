require 'spec_helper'

describe "Users" do      
  describe "sign up process" do
    context "when a user is not in the beta signup list" do
      it "should not let the user create an account" do
        visit sign_up_path
        fill_in 'Email', :with => 'joe@citizen.org'
        fill_in 'Password', :with => 'password'
        fill_in 'Password confirmation', :with => 'password'
        click_button 'Sign up'
        page.should have_content "I'm sorry, your account hasn't been approved yet."
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
          click_button 'Sign up'
          page.should have_content "I'm sorry, your account hasn't been approved yet."
        end
      end
    
      context "when a user has been approved" do
        before do
          BetaSignup.find_by_email('joe@citizen.org').update_attributes(:is_approved => true)
        end
      
        it "should let the user create an account" do
          visit sign_up_path
          fill_in 'Email', :with => 'joe@citizen.org'
          fill_in 'Password', :with => 'password'
          fill_in 'Password confirmation', :with => 'password'
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
            click_button 'Sign up'
            page.should have_content 'Thank you for signing up'

            user = User.find_by_email('joe@citizen.org')
            visit user_confirmation_path(:confirmation_token => user.confirmation_token)
            page.should have_content "Tell us a little about yourself"
            fill_in 'Zip code', :with => '12345'
            click_button 'Continue'
            page.should have_content "Tell us a little about yourself"
            check 'Married'
            check 'Parent'
            click_button 'Continue'
            page.should have_content 'MyGov Dashboard'
            user.reload
            user.zip.should == "12345"
            user.marital_status.should == "Married"
            user.is_parent.should == true
            user.is_veteran.should be_nil
            
            visit profile_path
            page.should have_content "12345"
          end
        end
        
        context "when a user signs up but enters bad information" do
          it "should display an error message" do
            visit sign_up_path
            fill_in 'Email', :with => 'joe@citizen.org'
            fill_in 'Password', :with => 'password'
            fill_in 'Password confirmation', :with => 'password'
            click_button 'Sign up'
            page.should have_content 'Thank you for signing up'

            user = User.find_by_email('joe@citizen.org')
            visit user_confirmation_path(:confirmation_token => user.confirmation_token)
            page.should have_content "Tell us a little about yourself"
            fill_in 'Zip code', :with => '1234'
            click_button 'Continue'
            page.should have_content "Please enter your 5 digit zip code."
          end
        end

        context "when a user signs up via a third party" do
          it "should collect information from the user in welcoming them to MyGov" do
            visit sign_up_path
            click_link 'Sign in with Google'
            page.should have_content "Tell us a little about yourself"
            fill_in 'Zip code', :with => '12345'
            click_button 'Continue'
            page.should have_content "Tell us a little about yourself"
            check 'Married'
            check 'Parent'
            click_button 'Continue'
            page.should have_content 'MyGov Dashboard'
            user = User.find_by_email('joe@citizen.org')
            user.zip.should == "12345"
            user.date_of_birth.should be_nil
            user.marital_status.should == "Married"
            user.is_parent.should == true
            user.is_veteran.should be_nil
            
            visit profile_path
            page.should have_content "12345"
          end
        end
      end
    end
  end
end