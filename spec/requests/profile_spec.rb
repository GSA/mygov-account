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
          page.should have_content "My Profile"
          expect(page.find('#profile_first_name').value).to eq('Joe')
          expect(page.find('#profile_last_name').value).to eq('Citizen')
          expect(page.find('#profile_is_retired').checked?).to eq(nil)
          expect(page.find('#profile_is_student').checked?).to eq('checked')
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
            choose 'profile_gender_male'
            select 'Married', :from => "Marital status"
            check "Parent"
            uncheck "Student"
            click_button "Update profile"

            expect(page.find('#profile_middle_name').value).to eq('Q')
            expect(page.find('#profile_address').value).to eq('123 Evergreen Terrace')
            expect(page.find('#profile_city').value).to eq('Springfield')
            expect(page.find('#profile_state').value).to eq('IA')
            expect(page.find('#profile_zip').value).to eq('12345')
            expect(page.find('#profile_phone_number').value).to eq('123-456-7890')
            expect(page.find('#profile_gender_male').checked?).to eq('checked')
            expect(page.find('#profile_marital_status').value).to eq('married')
            expect(page.find('#profile_is_parent').checked?).to eq('checked')
            expect(page.find('#profile_is_student').checked?).to eq(nil)
          end
        end
      end
    end
  end
end
