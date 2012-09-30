require 'spec_helper'

describe "Apps" do
  describe "GET /apps/:slug" do
    before do
      @app = App.create!(:name => 'Change your name')
      @married_form = @app.forms.create!(:call_to_action => 'Get Married!', :name => 'Getting Married Form', :url => 'http://example.gov/married.pdf')
      @married_pdf = Pdf.create!(:name => 'Form 123 - Getting Married', :url => 'http://example.gov/married.pdf', :form_id => @married_form.id)
      @divorced_form = @app.forms.create!(:call_to_action => 'Get Divorced!', :name => 'Getting Divorced Form', :url => 'http://example.gov/divorced.pdf')
      @divorced_pdf = Pdf.create!(:name => 'Form 789 - Getting Divorced', :url => 'http://example.gov/divorced.pdf', :form_id => @divorced_form.id)
      @married_form.criteria << @app.criteria.create!(:label => 'Getting Married')
      @divorced_form.criteria << @app.criteria.create!(:label => 'Getting Divorced')
    end
    
    it "should show a page for the app" do
      visit app_path(@app)
      page.should have_content @app.name
    end
    
    context "when not logged in" do
      it "should let a user provide a reason for filling out the form(s) and provide boiler plate information that can be saved" do
        visit app_path(@app)
        page.should have_content 'Getting Married'
        page.should have_content 'Getting Divorced'
        check 'Getting Married'
        click_button 'Continue'
        page.should have_content @married_form.call_to_action
        page.should have_no_content @divorced_form.call_to_action
        click_button 'Continue'
        page.should have_content "Let's begin with a few simple questions."
        fill_in 'First name', :with => 'Joe'
        fill_in 'Middle name', :with => 'Q.'
        fill_in 'Last name', :with => 'Citizen'
        click_button 'Continue'
        page.should have_content "Your primary address (where you live most of the time)."
        fill_in 'Street Address (first line)', :with => '123 Evergreen Terr'
        fill_in 'City or town', :with => 'Springfield'
        select 'Illinois', :from => 'State'
        fill_in 'Zip code', :with => '12345'
        click_button 'Continue'
        page.should have_content "When were you born?"
        select "1990", :from => 'user_date_of_birth_1i'
        select "January", :from => 'user_date_of_birth_2i'
        select "1", :form => 'user_date_of_birth_3i'
        click_button 'Continue'
        page.should have_content 'Contact information'
        fill_in 'Email', :with => 'joe.q.citizen@gmail.com'
        fill_in 'Phone', :with => '123-345-5667'
        click_button 'Continue'
        page.should have_content 'Review your information'
        click_button 'Continue to Download Forms'
        page.should have_content "Good job! Now we're going to take all that info you gave us and pre-fill as much of the form(s) as we can."
        click_link 'save-button'
        page.should have_content 'Save your information'
        page.should have_content 'Introducing MyGov, your online guide to to navigating government'

        # fake-login the user
        @user = User.create!(:email => 'joe@citizen.org', :first_name => 'Joe', :last_name => 'Citizen', :provider => 'Google', :uid => 'joe@citizen.org')
        create_logged_in_user(@user)
        
        visit finish_app_path(@app, :update_profile => "1")
        page.should have_content "Change your name"
        page.should have_content "Get Married!"
        click_link '/profile'
        page.should have_content '123 Evergreen Terr'
        page.should have_no_content 'joe.q.citizen@gmail.com'
      end
      
      it "should allow a user to go back and edit the information they filled out" do
        visit app_path(@app)
        page.should have_content 'Getting Married'
        page.should have_content 'Getting Divorced'
        check 'Getting Married'
        click_button 'Continue'
        page.should have_content @married_form.call_to_action
        page.should have_no_content @divorced_form.call_to_action
        click_button 'Continue'
        page.should have_content "Let's begin with a few simple questions."
        fill_in 'First name', :with => 'Joe'
        fill_in 'Middle name', :with => 'Q.'
        fill_in 'Last name', :with => 'Citizen'
        click_button 'Continue'
        page.should have_content "Your primary address (where you live most of the time)."
        fill_in 'Street Address (first line)', :with => '123 Evergreen Terr'
        fill_in 'City or town', :with => 'Springfield'
        select 'Illinois', :from => 'State'
        fill_in 'Zip code', :with => '12345'
        click_button 'Continue'
        page.should have_content "When were you born?"
        select "1990", :from => 'user_date_of_birth_1i'
        select "January", :from => 'user_date_of_birth_2i'
        select "1", :form => 'user_date_of_birth_3i'
        click_button 'Continue'
        page.should have_content 'Contact information'
        fill_in 'Email', :with => 'joe.q.citizen@gmail.com'
        fill_in 'Phone', :with => '123-456-7890'
        fill_in 'Mobile', :with => '234-5678900'
        click_button 'Continue'
        page.should have_content 'Review your information'
        
        # Edit your name
        click_button 'Edit Name'
        page.should have_field 'First name', :with => 'Joe'
        fill_in 'First name', :with => 'John'
        click_button 'Continue'
        page.should have_content 'Review your information'
        page.should have_content 'John'
        page.should have_no_content 'Joe'
        
        # Edit your address
        click_button 'Edit Address'
        page.should have_field 'Zip code', :with => '12345'
        fill_in 'Zip code', with: '23456'
        click_button 'Continue'
        page.should have_content 'Review your information'
        page.should have_content'23456'
        page.should have_no_content '12345'
        
        # Edit date of birth
        click_button 'Edit Date of Birth'
        page.should have_field 'user_date_of_birth_1i', :with => '1990'
        select '1991', :from => 'user_date_of_birth_1i'
        click_button 'Continue'
        page.should have_content 'Review your information'
        page.should have_content '1991'
        page.should have_no_content '1990'
        
        # Edit contact info
        click_button 'Edit Contact Information'
        page.body.should =~ /joe.q.citizen@gmail.com/
        page.should have_field 'Phone', :with => '123-456-7890'
        page.should have_field 'Mobile', :with => '234-567-8900'
        fill_in 'Email', :with => 'joe.q.citizen@yahoo.com'
        fill_in 'Mobile', :with => '2345678901'
        click_button 'Continue'
        page.should have_content 'Review your information'
        page.should have_content 'joe.q.citizen@yahoo.com'
        page.should have_no_content 'joe.q.citizen@gmail.com'
        page.should have_content '234-567-8901'
      end
      
      it "should allow a user to download a PDF pre-filled with profile information they provided" do
        visit app_path(@app)
        check 'Getting Married'
        click_button 'Continue'
        click_button 'Continue'
        fill_in 'First name', :with => 'Joe'
        fill_in 'Middle name', :with => 'Q.'
        fill_in 'Last name', :with => 'Citizen'
        click_button 'Continue'
        fill_in 'Street Address (first line)', :with => '123 Evergreen Terr'
        fill_in 'City or town', :with => 'Springfield'
        select 'Illinois', :from => 'State'
        fill_in 'Zip', :with => '12345'
        click_button 'Continue'
        select "1990", :from => 'user_date_of_birth_1i'
        select "January", :from => 'user_date_of_birth_2i'
        select "1", :form => 'user_date_of_birth_3i'
        click_button 'Continue'
        fill_in 'Email', :with => 'joe.q.citizen@gmail.com'
        fill_in 'Phone', :with => '123-345-5667'
        click_button 'Continue'
        click_button 'Continue to Download Forms'
        page.should have_content "Download Getting Married Form (PDF)"
      end
    end
    
    context "when logged in" do
      before do
        @user = User.create!(:email => 'joe@citizen.org', :first_name => 'Joe', :last_name => 'Citizen', :provider => 'Google', :uid => 'joe@citizen.org', :zip => '12345', :date_of_birth => Date.parse('1990-01-01'))
        create_logged_in_user(@user)
      end

      it "should take the user right to the summary page, filled with data from their profile, and allow them to jump back and edit" do
        visit app_path(@app)
        page.should have_content 'Getting Married'
        page.should have_content 'Getting Divorced'
        check 'Getting Married'
        click_button 'Continue'
        page.should have_content @married_form.call_to_action
        page.should have_no_content @divorced_form.call_to_action
        click_button 'Continue'
        page.should have_content 'Review your information'
        page.should have_content 'Joe'
        page.should have_content 'Citizen'
        page.should have_content '12345'
        page.should have_content '1990-01-01'
        page.should have_content 'joe@citizen.org'
        
        # Edit your name
        click_button 'Edit Name'
        page.should have_field 'First name', :with => 'Joe'
        fill_in 'First name', :with => 'John'
        click_button 'Continue'
        page.should have_content 'Review your information'
        page.should have_content 'John'
        page.should have_no_content 'Joe'
        
        # Edit your address
        click_button 'Edit Address'
        page.should have_field 'Zip code', :with => '12345'
        fill_in 'Zip code', with: '23456'
        click_button 'Continue'
        page.should have_content 'Review your information'
        page.should have_content'23456'
        page.should have_no_content '12345'
        
        # Edit date of birth
        click_button 'Edit Date of Birth'
        page.should have_field 'user_date_of_birth_1i', :with => '1990'
        select '1991', :from => 'user_date_of_birth_1i'
        click_button 'Continue'
        page.should have_content 'Review your information'
        page.should have_content '1991'
        page.should have_no_content '1990'
        
        # Edit contact info
        click_button 'Edit Contact Information'
        page.body.should =~ /joe@citizen.org/
        fill_in 'Email', :with => 'joe.q.citizen@yahoo.com'
        click_button 'Continue'
        page.should have_content 'Review your information'
        page.should have_content 'joe.q.citizen@yahoo.com'
        page.should have_no_content 'joe@citizen.org'
        
        uncheck 'Save this to your MyGov Profile'
        click_button 'Continue to Download Forms'
        page.should have_content "Good job! Now we're going to take all that info you gave us and pre-fill as much of the form(s) as we can."
        click_link 'save-button'
        page.should have_content "Change your name"
        page.should have_content "Get Married!"
        click_link '/profile'
        page.should have_content '12345'
        page.should have_no_content '23456'
        page.should have_no_content 'joe@citizen.org'
      end
      
      it "should save the updated information to the user's profile if they select to save" do
        visit app_path(@app)
        page.should have_content 'Getting Married'
        page.should have_content 'Getting Divorced'
        check 'Getting Married'
        click_button 'Continue'
        page.should have_content @married_form.call_to_action
        page.should have_no_content @divorced_form.call_to_action
        click_button 'Continue'
        page.should have_content 'Review your information'
        
        # Edit your address
        click_button 'Edit Address'
        page.should have_field 'Zip code', :with => '12345'
        fill_in 'Zip code', with: '23456'
        click_button 'Continue'
        page.should have_content 'Review your information'
        page.should have_content'23456'
        page.should have_no_content '12345'
        
        click_button 'Continue to Download Forms'
        page.should have_content "Good job! Now we're going to take all that info you gave us and pre-fill as much of the form(s) as we can."
        click_link 'save-button'
        page.should have_content "Change your name"
        page.should have_content "Get Married!"
        click_link '/profile'
        page.should have_content'23456'
        page.should have_no_content '12345'
        page.should have_no_content 'joe@citizen.org'
      end
      
      it "should provide a link to a PDF with the user's information" do
        visit app_path(@app)
        check 'Getting Married'
        click_button 'Continue'
        click_button 'Continue'
        click_button 'Continue to Download Forms'
        page.should have_content "Download Getting Married Form (PDF)"
      end
    end
  end
end