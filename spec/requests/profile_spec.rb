require 'spec_helper'

describe "Profile" do
  before do
    @user = create_confirmed_user_with_profile(:is_student => true)
  end

  describe "GET /profile" do    
    context "when visiting the web site via a browser" do
      context "when logged in" do
        before {login(@user)}

        it "should show a user their profile" do
          visit profile_path
          page.should have_content "Your profile"
          page.should have_content "First name: Joe"
          page.should have_content "Last name: Citizen"
          page.should have_content "Edit your profile"
          page.should have_content "Retired: No"
          page.should have_content "Student: Yes"
        end
      
        context "editing your profile" do
          it "should perform validations on zip when updating a profile with information provided by the user" do
            visit profile_path
            click_link "Edit your profile"
            page.should have_content 'Paperwork Reduction Act Statement'
            fill_in "Zip", :with => '12X45'
            click_button "Update profile"
            page.should have_content "Something went wrong"
          end
          
          it "should perform validations on phone when updating a profile with information provided by the user" do
            visit profile_path
            click_link "Edit your profile"
            page.should have_content 'Paperwork Reduction Act Statement'
            fill_in "Phone", :with => '111-222-3x44'
            click_button "Update profile"
            page.should have_content "Something went wrong"
          end
          
          it "should update the profile with new information provided by the user" do
            visit profile_path
            click_link "Edit your profile"
            page.should have_content 'Paperwork Reduction Act Statement'
            fill_in "Middle name", :with => "Q"
            fill_in "Address", :with => "123 Evergreen Terrace"
            fill_in "City", :with => 'Springfield'
            select "Iowa", :from => 'State'
            fill_in "Zip", :with => '12345'
            fill_in "Phone", :with => '(123) 456-7890' # using a different format to test auto-formatting
            select 'Male', :from => 'Gender'
            select 'Married', :from => "Marital status"
            check "Parent"
            uncheck "Student"
            click_button "Update profile"
            page.should have_content "Middle name: Q"
            page.should have_content "Address: 123 Evergreen Terrace"
            page.should have_content "City: Springfield"
            page.should have_content "State: IA"
            page.should have_content "Zip: 12345"
            page.should have_content "Phone: 123-456-7890"
            page.should have_content "Gender: Male"
            page.should have_content "Marital status: Married"
            page.should have_content "Parent: Yes"
            page.should have_content "Student: No"
          end
        end
      end
    end
  end
end
