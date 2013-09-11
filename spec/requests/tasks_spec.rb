require 'spec_helper'

describe "Tasks" do
  describe "GET /task/:id" do
    before do
      create_confirmed_user_with_profile
      login(@user)
      @app = App.create!(:name => 'Change your name', :redirect_uri => "http://localhost:3000/")
      
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
