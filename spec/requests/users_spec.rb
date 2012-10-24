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
        page.should have_content 'Thanks for signing up!'
        ActionMailer::Base.deliveries.last.to.should == ['joe@citizen.org']
        ActionMailer::Base.deliveries.last.from.should == ["no-reply@my.usa.gov"]
      end
    end    
  end
end