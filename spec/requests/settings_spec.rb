# require 'spec_helper'

# describe "Settings Page" do
#   before {create_confirmed_user}

#   describe "GET /settings" do
#     context "when the user is logged in" do
#       before {login(@user)}

#       it "should show the user a link to change their email address" do
#         visit settings_path
#         page.should have_content("Change email address")
#       end
#     end
#   end

#   describe "GET /user/edit" do
#     context "when the user is logged in" do
#       before {login(@user)}

#       it "should allow password change" do
#         visit settings_path(@user)
#         click_link 'Change your password'
#         fill_in('user_password', :with => 'asdf')      # Fill in with invalid input to test validation
#         click_button('Change my password')
#         page.should have_content("Password doesn't match confirmation")
#         new_password = get_random_password
#         fill_in('user_password', :with => new_password) # Use valid password, different from create_confirmed_user pasword
#         fill_in('user_password_confirmation', :with => new_password)
#         click_button('Change my password')
#         page.should have_content("Your password was sucessfully updated.")
#         click_link 'Logout'                           # Sign out and sign back in
#         fill_in 'Email', :with => 'joe@citizen.org'
#         fill_in 'Password', :with => new_password
#         click_button 'Sign in'
#         current_path.should match('dashboard')

#       end


      # it "should show the user a form with their current email address filled in" do
      #   visit edit_user_registration_path(@user)
      #   email_field = find_field('Email')
      #   email_field[:value].should == 'joe@citizen.org'
      # end

#       it "should let the user change their email address" do
#         visit edit_user_registration_path(@user)
#         fill_in('Email', :with => 'jack@citizen.org')
#         fill_in('Current password', :with => 'Password1')
#         click_button('Update')
#         page.should have_no_content('your account hasn\'t been approved yet')
#         expect(page).to have_content('You updated your account successfully, but we need to verify your new email address.')
#         page.body.should =~ /jack/
#         page.body.should_not =~ /joe/
#         @user.reload
#         @user.unconfirmed_email.should eq 'jack@citizen.org'
#         email = ActionMailer::Base.deliveries.last
#         email.to.should eq ['jack@citizen.org']
#         email.from.should eq ["projectmyusa@gsa.gov"]
#         expect(email.body).not_to include('joe@citizen.org')
#       end

#       it "should not allow the user change their email address to an invalid value" do
#         visit edit_user_registration_path(@user)
#         fill_in('Email', :with => 'chaudet, roy@epa.gov')
#         fill_in('Current password', :with => 'Password1')
#         click_button('Update')
#         # Change the rest of this to the invalid message
#         expect(page).to have_no_content('You updated your account successfully, but we need to verify your new email address.')
#         page.should have_content('Email does not appear to be valid')
#         page.should_not have_content('Email is invalid')
#       end

#       context "when the user changes their email address" do
#         it "should change their beta invite address once they have confirmed the new one" do
#           visit edit_user_registration_path(@user)
#           fill_in('Email', :with => 'jack@citizen.org')
#           fill_in('Current password', :with => 'Password1')
#           click_button('Update')
#           BetaSignup.where(:email => 'jack@citizen.org').count.should eq 0
#           BetaSignup.where(:email => 'joe@citizen.org').count.should eq 1
#           @user.reload
#           @user.confirm!
#           BetaSignup.where(:email => 'jack@citizen.org').count.should eq 1
#           BetaSignup.where(:email => 'joe@citizen.org').count.should eq 0
#         end
#       end
#     end
#   end
# end
