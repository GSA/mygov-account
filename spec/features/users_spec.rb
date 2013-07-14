require 'spec_helper'

describe "Users" do
  describe "sign-in links" do
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
      before do
        create_approved_beta_signup('joe@citizen.org')      
        @user = User.create(:email => 'joe@citizen.org', :password => 'Password1')
        @user.confirm!
        create_logged_in_user(@user)
      end
      
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
        fill_in 'Email', :with => 'joe@citizen.org'
        fill_in 'Password', :with => 'Password1'
        fill_in 'Password confirmation', :with => 'Password1'
        check 'I agree to the MyUSA Terms of Service and Privacy Policy'
        click_button 'Sign up'
        page.should have_content "I'm sorry, your account hasn't been approved yet."
      end
      
      it "should not let the user create an approved beta signup record by manipulating the post" do
        test_email = 'shady@citizen.org&is_approved=1'
        visit sign_up_path
        begin
          # post :beta_signups_path, 'beta_signup' => { 'email' => test_email, 'is_approved' => '1' }
          click_button 'Sign up'
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
      
      context "when a user has not been approved" do
        it "should not let the user create an account" do
          visit sign_up_path
          fill_in 'Email', :with => 'joe@citizen.org'
          fill_in 'Password', :with => 'Password1'
          fill_in 'Password confirmation', :with => 'Password1'
          check 'I agree to the MyUSA Terms of Service and Privacy Policy'
          click_button 'Sign up'
          page.should have_content "I'm sorry, your account hasn't been approved yet."
        end
      end
    
      context "when a user has been approved" do
        before do
          BetaSignup.find_by_email('joe@citizen.org').update_attribute(:is_approved, true)
        end
        
        context "when the user does not accept the terms of serivce and privacy policy" do
          context "when the user fills in everything else" do
            it "should not register the user and display an error message" do
              visit sign_up_path
              fill_in 'Email', :with => 'joe@citizen.org'
              fill_in 'Password', :with => 'Password1'
              fill_in 'Password confirmation', :with => 'Password1'
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
            fill_in 'Email', :with => 'joe@citizen.org'
            fill_in 'Password', :with => 'Password1'
            fill_in 'Password confirmation', :with => 'Password1'
            check 'I agree to the MyUSA Terms of Service and Privacy Policy'
            click_button 'Sign up'
            page.should have_content 'Thank you for signing up'
            ActionMailer::Base.deliveries.last.to.should == ['joe@citizen.org']
            ActionMailer::Base.deliveries.last.from.should == ["projectmyusa@gsa.gov"]
          end
          
          context "when the user submits a password that has less than 8 characters" do
            it "should not create the user account" do
              visit sign_up_path
              fill_in 'Email', :with => 'joe@citizen.org'
              fill_in 'Password', :with => 'pass'
              fill_in 'Password confirmation', :with => 'pass'
              check 'I agree to the MyUSA Terms of Service and Privacy Policy'
              click_button 'Sign up'
              page.should have_content 'Password is too short (minimum is 8 characters)'
            end
          end
          
          context "when the user submits a password that isn't sufficiently strong" do
            it "should not create the user account" do
              visit sign_up_path
              fill_in 'Email', :with => 'joe@citizen.org'
              fill_in 'Password', :with => 'password'
              fill_in 'Password confirmation', :with => 'password'
              check 'I agree to the MyUSA Terms of Service and Privacy Policy'
              click_button 'Sign up'
              page.should have_content 'must include at least one lower case letter, one upper case letter and one digit.'
            end
          end
          
          context "when the user submits a password with special characters" do
            it "should create an account" do
              visit sign_up_path
              fill_in 'Email', :with => 'joe@citizen.org'
              fill_in 'Password', :with => 'Password!2'
              fill_in 'Password confirmation', :with => 'Password!2'
              check 'I agree to the MyUSA Terms of Service and Privacy Policy'
              click_button 'Sign up'
              page.should have_content 'Thank you for signing up'
            end
          end 
        end
        
        context "when a third-party user exists with the same email but a different uid and provider" do
          before do
            user = User.new(:email => 'joe@citizen.org', :password => 'Password1')
            auth = Authentication.new(:provider => 'other_provider', :uid => 'joe@citizen.org', :user => user)
            user.save!
          end
          
          it "should not allow a new user to be created or login with that email address" do
            visit sign_up_path
            fill_in 'Email', :with => 'joe@citizen.org'
            fill_in 'Password', :with => 'Password1'
            fill_in 'Password confirmation', :with => 'Password1'
            check 'I agree to the MyUSA Terms of Service and Privacy Policy'
            click_button 'Sign up'
            page.should have_content 'Email has already been taken'
          end
        end
        
        context "when a local user exists with the same email" do
          before do
            user = User.new(:email => 'joe@citizen.org', :password => 'Password1')
            user.save!
          end
          
          it "should not let someone sign in with a third party service that identifies the user with the same email" do
            visit sign_in_path
            click_link 'Sign in with Google'
            page.should have_content 'We already have an account with that email. Make sure login with the service you used to create the account.'
          end
        end 
      end
    end
  end

  describe "sign in process" do
    before do
      create_approved_beta_signup('joe@citizen.org')
      @user = User.create(:email => 'joe@citizen.org', :password => 'Password1')
      @user.confirm!
    end
    
    it "should lock the account if the user fails to login five times" do
      visit sign_in_path
      6.times do
        fill_in 'Email', :with => 'joe@citizen.org'
        fill_in 'Password', :with => 'wordpass'
        click_button 'Sign in'
      end
      page.should have_content "Your account is locked."
      @user.reload
      @user.unlock_token.should_not be_nil
      ActionMailer::Base.deliveries.last.to.should == ['joe@citizen.org']
      ActionMailer::Base.deliveries.last.subject.should == 'Unlock Instructions'
    end
    
    context "when the user has connected their MAX.gov account" do
      before do
        @user.authentications.create(:provider => "max.gov", :uid => 'joe.citizen@usa.gov')
      end
      
      it "should allow the user to log in using their MAX.gov account" do
        visit sign_in_path
        click_link 'More sign in options'
        click_link 'Sign in with MAX.gov'
        page.should have_content 'Your profile'
      end
    end
  end
    
  describe "sign out process" do
    before do
      create_approved_beta_signup('joe@citizen.org')      
      @user = User.create(:email => 'joe@citizen.org', :password => 'Password1')
      @user.confirm!
      create_logged_in_user(@user)
    end
    
    it "should redirect the user to the sign in page" do
      visit dashboard_path
      click_link 'Sign out'
      page.should have_content "Sign in"
      page.should have_content "Didn't receive confirmation instructions?"
    end
  end
end