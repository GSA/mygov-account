require 'spec_helper'

describe "Profile" do
  before {create_confirmed_user_with_profile}

  describe "GET /profile" do
    context "when visiting the web site via a browser" do
      context "when logged in" do
        before {login(@user)}

        it "should show a user their profile" do
          visit profile_path
          page.should have_content "My Profile"
          expect(page.find('#profile_first_name').value).to eq('Joe')
          expect(page.find('#profile_last_name').value).to eq('Citizen')
          expect(page.find('#profile_is_retired').checked?).to eq(nil)
          expect(page.find('#profile_is_student').checked?).to eq('checked')
          #TODO: Update page
        end

        context "editing your profile" do
          it "should perform validations on zip when updating a profile with information provided by the user" do
            visit profile_path
            page.should have_content 'Paperwork Reduction Act Statement'
            fill_in "Zip", :with => '12X45'
            click_button "Update profile"
            page.should have_content "Something went wrong"
          end

          it "should perform validations on phone when updating a profile with information provided by the user" do
            visit profile_path
            page.should have_content 'Paperwork Reduction Act Statement'
            fill_in "Phone", :with => '111-222-3x44'
            click_button "Update profile"
            page.should have_content "Something went wrong"
          end

          it "should update the profile with new information provided by the user" do
            visit profile_path
            page.should have_content 'Paperwork Reduction Act Statement'
            fill_in "Middle name", :with => "Q"
            fill_in "Address", :with => "123 Evergreen Terrace"
            fill_in "City", :with => 'Springfield'
            select "Iowa", :from => 'State'
            fill_in "Zip", :with => '12345'
            fill_in "Phone", :with => '(123) 456-7890' # using a different format to test auto-formatting
            choose 'gender_male'
            select 'Married', :from => "Marital status"
            check "Parent"
            uncheck "Student"
            click_button "Update profile"
            # page.should have_content "Middle name: Q"
            expect(page.find('#profile_middle_name').value).to eq('Q')
            # page.should have_content "Address: 123 Evergreen Terrace"
            # expect(page.find('#profile_address').value).to eq('123 Evergreen Terrace')
            expect(page.find('#profile_address').value).to eq('123 Evergreen Terrace')
            # page.should have_content "City: Springfield"
            expect(page.find('#profile_city').value).to eq('Springfield')
            # page.should have_content "State: IA"
            expect(page.find('#profile_state').value).to eq('IA')
            # page.should have_content "Zip: 12345"
            expect(page.find('#profile_zip').value).to eq('12345')
            # page.should have_content "Phone: 123-456-7890"
            expect(page.find('#profile_phone').value).to eq('123-456-7890')
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
