require 'spec_helper'

describe "Apps" do
  describe "GET /apps/:slug" do
    before do
      @app = App.create!(:name => 'Change your name')
      @married_form = @app.forms.create!(:call_to_action => 'Get Married!', :name => 'Getting Married Form', :url => 'http://example.gov/married.pdf')
      @divorced_form = @app.forms.create!(:call_to_action => 'Get Divorced!', :name => 'Getting Divorced Form', :url => 'http://example.gov/divorced.pdf')
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
        page.should_not have_content @divorced_form.call_to_action
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
        fill_in 'Zip', :with => '12345'
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
        page.should have_content "Good job! Now we're going to take all that info you gave us and pre-fill as much of the form(s) as we can."
        click_link 'save-button'
        page.should have_content 'Save your information'
        page.should have_content 'Introducing MyGov, your online guide to to navigating government'

        # fake-login the user
        @user = User.create!(:email => 'joe@citizen.org', :first_name => 'Joe', :last_name => 'Citizen', :provider => 'Google', :uid => 'joe@citizen.org')
        create_logged_in_user(@user)
        
        visit finish_app_path(@app)
        page.should have_content "Change your name"
        page.should have_content "1 Forms / Possible Tasks"
        click_link '/profile'
        page.should have_content '123 Evergreen Terr'
        page.should_not have_content 'joe.q.citizen@gmail.com'
      end      
    end 
  end
end
