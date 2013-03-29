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
        page.should have_link 'Sign in with PayPal'
        page.should have_link 'Sign in with VeriSign'
      end
      
      it "should not have a sign-in link on the sign-in page" do
        visit sign_in_path
        page.should_not have_content "Already using MyUSA?"
      end
    end
    
    context "when a user is signed in" do
      before do
        beta_signup = BetaSignup.new(:email => 'joe@citizen.org')
        beta_signup.is_approved = true
        beta_signup.save!
        @user = User.create(:email => beta_signup.email, :password => 'password')
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
      page.should have_link 'Sign up with PayPal'
      page.should have_link 'Sign up with VeriSign'
    end
    
    context "when a user is not in the beta signup list" do
      it "should not let the user create an account" do
        visit sign_up_path
        fill_in 'Email', :with => 'joe@citizen.org'
        fill_in 'Password', :with => 'password'
        fill_in 'Password confirmation', :with => 'password'
        check 'I agree to the MyUSA Terms of Service and Privacy Policy'
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
      
      context "when a user has not been approved" do
        it "should not let the user create an account" do
          visit sign_up_path
          fill_in 'Email', :with => 'joe@citizen.org'
          fill_in 'Password', :with => 'password'
          fill_in 'Password confirmation', :with => 'password'
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
              fill_in 'Password', :with => 'password'
              fill_in 'Password confirmation', :with => 'password'
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
        
        it "should let the user create an account" do
          visit sign_up_path
          fill_in 'Email', :with => 'joe@citizen.org'
          fill_in 'Password', :with => 'password'
          fill_in 'Password confirmation', :with => 'password'
          check 'I agree to the MyUSA Terms of Service and Privacy Policy'
          click_button 'Sign up'
          page.should have_content 'Thank you for signing up'
          ActionMailer::Base.deliveries.last.to.should == ['joe@citizen.org']
          ActionMailer::Base.deliveries.last.from.should == ["projectmygov@gsa.gov"]
        end
        
        it "should set the user's name" do
          visit sign_up_path
          fill_in 'Email', :with => 'joe@citizen.org'
          fill_in 'Password', :with => 'password'
          fill_in 'Password confirmation', :with => 'password'
          check 'I agree to the MyUSA Terms of Service and Privacy Policy'
          click_button 'Sign up'
          page.should have_content 'Thank you for signing up'
          ActionMailer::Base.deliveries.last.to.should == ['joe@citizen.org']
          ActionMailer::Base.deliveries.last.from.should == ["projectmygov@gsa.gov"]
        end    
      end
    end
  end

  describe "sign out process" do
    before do
      beta_signup = BetaSignup.new(:email => 'joe@citizen.org')
      beta_signup.is_approved = true
      beta_signup.save!
      @user = User.create(:email => beta_signup.email, :password => 'password')
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