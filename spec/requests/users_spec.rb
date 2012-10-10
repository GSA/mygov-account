require 'spec_helper'

describe "Users" do
  describe "beta sign up process" do
    before do
      BetaSignup.destroy_all
    end
    
    it "should allow a user add their email to the beta list, and send them an email when they do" do
      visit root_path
      page.should have_content "Sign up for the MyGov Beta!"
      fill_in 'Email', :with => 'joe@citizen.org'
      click_button 'Sign up'
      beta_signup = BetaSignup.find_by_email("joe@citizen.org")
      beta_signup.should_not be_nil
      beta_signup.is_approved.should be_false
      ActionMailer::Base.deliveries.last.to.should == ['joe@citizen.org']
      ActionMailer::Base.deliveries.last.subject.should == 'Thanks for signing up for MyGov!'
    end
  end
      
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
    
    context "when a user is in the beta signup list, but hasn't been approved" do
      before do
        BetaSignup.create!(:email => 'joe@citizen.org')
      end
      
      it "should not let the user create an account" do
        visit sign_up_path
        fill_in 'Email', :with => 'joe@citizen.org'
        fill_in 'Password', :with => 'password'
        fill_in 'Password confirmation', :with => 'password'
        click_button 'Sign up'
        page.should have_content "I'm sorry, your account hasn't been approved yet."
      end
    end
    
    context "when a user is in the beta signup list and has been approved" do
      before do
        BetaSignup.create!(:email => 'joe@citizen.org', :is_approved => true)
      end
      
      it "should not let the user create an account" do
        visit sign_up_path
        fill_in 'Email', :with => 'joe@citizen.org'
        fill_in 'Password', :with => 'password'
        fill_in 'Password confirmation', :with => 'password'
        click_button 'Sign up'
        page.should have_content 'MyGov Dashboard'
      end
    end    
  end
end
