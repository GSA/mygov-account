require 'spec_helper'

describe "Users" do
  describe "sign up process" do
    it "should allow a user to sign up with an email and password, and redirect them to a thank you page, and then not allow them to log in" do
      visit sign_up_path
      fill_in 'Email', :with => 'joe@citizen.org'
      fill_in 'Password', :with => 'password'
      fill_in 'Password confirmation', :with => 'password'
      click_button 'Sign up'
      page.should have_content 'Thank you for signing up for MyGov!'
      visit sign_in_path
      fill_in 'Email', :with => 'joe@citizen.org'
      fill_in 'Password', :with => 'password'
      click_button 'Sign in'
      page.should have_content 'Your account has not been approved by your administrator yet.'
    end
    
    it "should send an email to a user when their account is approved" do
      visit sign_up_path
      fill_in 'Email', :with => 'joe@citizen.org'
      fill_in 'Password', :with => 'password'
      fill_in 'Password confirmation', :with => 'password'
      click_button 'Sign up'
      User.find_by_email('joe@citizen.org').update_attributes(:is_approved => true)
      ActionMailer::Base.deliveries.last.to.should == ['joe@citizen.org']
      ActionMailer::Base.deliveries.last.subject.should == 'Welcome to MyGov!'
    end
  end
end
