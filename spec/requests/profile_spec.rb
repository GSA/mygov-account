require 'spec_helper'

describe "Profile" do
  before do
    BetaSignup.create!(:email => 'joe@citizen.org', :is_approved => true)
    @user = User.create!(:email => 'joe@citizen.org', :password => 'random', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
  end

  describe "GET /profile" do    
    context "when visiting the web site via a browser" do
      context "when logged in" do
        before do
          create_logged_in_user(@user)
        end

        it "should show a user their profile" do
          visit profile_path
          page.should have_content "Your MyGov Profile"
          page.should have_content "First name: Joe"
          page.should have_content "Last name: Citizen"
          page.should have_content "Edit your Profile"
        end
      
        context "editing your profile" do
          it "should update the profile with new information provided by the user" do
            visit profile_path
            click_link "Edit your Profile"
            fill_in "Middle name", :with => "Q"
            fill_in "Address", :with => "123 Evergreen Terrace"
            fill_in "City", :with => 'Springfield'
            select "Iowa", :from => 'State'
            fill_in "Zip", :with => '12345'
            fill_in "Phone", :with => '123-456-7890'
            select 'Male', :from => 'Gender'
            select 'Married', :from => "Marital status"
            click_button "Update Profile"
            page.should have_content "Middle name: Q"
            page.should have_content "Address: 123 Evergreen Terrace"
            page.should have_content "City: Springfield"
            page.should have_content "State: IA"
            page.should have_content "Zip: 12345"
            page.should have_content "Phone: 123-456-7890"
            page.should have_content "Gender: Male"
            page.should have_content "Marital status: Married"
          end
        end
      end
    end
  end
end