require 'spec_helper'

describe "Tasks" do
  describe "GET /task/:id" do
    before do
      BetaSignup.create!(:email => 'joe@citizen.org', :is_approved => true)
      @user = User.create!(:email => 'joe@citizen.org', :password => 'random', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
      @user.confirm!

      @app = App.create!(:name => 'Change your name'){|app| app.redirect_uri = "http://localhost:3000/"}
      @married_pdf = Pdf.create!(:name => 'Form 123 - Getting Married', :url => 'http://example.gov/married.pdf')
      @divorced_pdf = Pdf.create!(:name => 'Form 789 - Getting Divorced', :url => 'http://example.gov/divorced.pdf')
      
      @task = @user.tasks.create!(:app_id => @app.id, :name => 'Change your name')
      @task.task_items.create!(:name => 'Get Married!')
      @task.task_items.create!(:name => 'Get Divorced!')
      
      create_logged_in_user(@user)
      visit task_path(@task)
    end
    
    it "should display a task with links to download pdfs" do
      page.should have_content(@task.app.name)
      @task.task_items.each{|task_item| page.should have_content(task_item.name) }
      page.should have_content "0 of 2 items completed."
    end
    
    it "should let a user mark all items as complete" do
      click_link 'Mark all items complete'
      page.should have_content 'MyGovBeta'
      visit task_path(@task)
      page.should have_content "2 of 2 items completed."
      page.should have_content "Task completed at"
      page.should have_content "Item completed at"
      page.should have_no_link "Mark all items complete"
      page.should have_no_link "Mark complete"
    end
    
    it "should let a user mark an individual task item as complete" do
      click_link 'Mark complete'
      page.should have_content "1 of 2 items completed."
      page.should have_link "Mark all items complete"
      page.should have_no_content "Task completed at"
      page.should have_content "Item completed at"
      page.should have_link "Mark complete"
    end
    
    it "should let a user remove an individual task item" do
      click_link "Remove"
      page.should have_content "0 of 1 items completed."
    end
    
    it "should complete the task if the user completes all the items" do
      click_link "Mark complete"
      click_link "Mark complete"
      page.should have_content "2 of 2 items completed."
      page.should have_content "Task completed at"
      page.should have_content "Item completed at"
      page.should have_no_link "Mark all items complete"
      page.should have_no_link "Mark complete"
    end
    
    it "should complete the task if the user removes all the items" do
      click_link "Remove"
      click_link "Remove"
      page.should have_content "0 of 0 items completed."
      page.should have_content "Task completed at"
      page.should have_no_content "Item completed at"
      page.should have_no_link "Mark all items complete"
      page.should have_no_link "Mark complete"
    end
  end
end
