require 'spec_helper'

describe "Tasks" do
  before do
    @user = create_confirmed_user_with_profile
    login(@user)
    @app = App.create!(:name => 'Change your name', :redirect_uri => "http://localhost:3000/")
  end
    
  describe "Get /tasks" do
    context "when the user has no tasks" do
      it "should inform the user that they have no tasks" do
        visit tasks_path
        page.should have_content "You currently have no tasks."
      end
    end
  
    context "when the user has tasks" do
      before do
       1.upto(11) do |index|
         @user.tasks.create!({:app_id => @app.id, :name => "Task ##{index}"}, :as => :admin)
       end
       visit tasks_path
     end
   
      it "should show a paginated list of tasks" do
        page.should have_content "Task #2"
        page.should have_link 'Next'
        page.should have_link '2'
        click_link 'Next'
        page.should have_link 'Previous'
        page.should have_content 'Task #11'
      end
      
      it "should automatically set the page to the lowest actual page" do
        page.should have_content "Task #2"
        click_link "Next"
        page.should have_content "Task #11"
        click_link "Delete"
        page.should have_content "Task #2"
        page.should have_content "Task #10"
      end
    end
  end
 
  describe "GET /task/:id" do
    before do      
      @task = @user.tasks.create!({:app_id => @app.id, :name => 'Change your name'}, :as => :admin)
      @task.task_items.create!(:name => 'Get Married!')
      @task.task_items.create!(:name => 'Get Divorced!')
      
      visit task_path(@task)
    end
    
    it "should display a task with links with the task item names" do
      page.should have_content(@task.app.name)
      @task.task_items.each{|task_item| page.should have_content(task_item.name) }
      page.should have_content "0 of 2 items completed."
    end
    
    it "should let a user mark all items as complete" do
      click_link 'Mark all items for Change your name complete'
      page.should have_content 'MyUSA'
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
      page.should have_link "Mark all items for Change your name complete"
      page.should have_no_content "Task completed at"
      page.should have_content "Item completed at"
      page.should have_link "Mark complete"
    end
    
    it "should let a user remove an individual task item" do
      click_link "Remove"
      page.should have_content "0 of 1 items completed."
    end
    
    it "should complete the task if the user completes all the items" do
      2.times {click_link "Mark complete"}
      page.should have_content "2 of 2 items completed."
      page.should have_content "Task completed at"
      page.should have_content "Item completed at"
      page.should have_no_link "Mark all items complete"
      page.should have_no_link "Mark complete"
    end
    
    it "should complete the task if the user removes all the items" do
      2.times {click_link "Remove"}
      page.should have_content "0 of 0 items completed."
      page.should have_content "Task completed at"
      page.should have_no_content "Item completed at"
      page.should have_no_link "Mark all items complete"
      page.should have_no_link "Mark complete"
    end
  end
end
