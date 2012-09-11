require 'spec_helper'

describe "Tasks" do
  before do
    @user = User.create!(:email => 'joe@citizen.org', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
    @app = App.create!(:name => 'Test App')
    @form1 = @app.forms.create!(:call_to_action => 'Form #1!', :name => 'Form 1', :url => 'http://example.gov/1.pdf')
    @form2 = @app.forms.create!(:call_to_action => 'Form #2!', :name => 'Form 2', :url => 'http://example.gov/2.pdf')
  end
  
  describe "GET /tasks/:id" do
    before do
      create_logged_in_user(@user)
      @user.tasks.create(:app_id => @app.id)
      @user.tasks.first.task_items.create(:form_id => @form1.id)
      @user.tasks.first.task_items.create(:form_id => @form2.id)
    end
    
    it "should show saved tasks on the home page, and let a user navigate to a specific task" do
      visit root_path
      page.should have_content "Saved Task List"
      page.should have_content "Test App"
      page.should have_content "2 Forms / Possible Tasks"
      click_link("2 Forms / Possible Tasks")
      page.should have_content "Test App"
      page.should have_content "Completed at: Not Completed"
      page.should have_content "Form 1"
      page.should have_content "Form 2"
      visit dashboard_path
      click_link("Remove")
      page.should_not have_content "Saved Task List"
      page.should_not have_content "My Task"
    end
  end  
end
