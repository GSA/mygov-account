require 'spec_helper'

describe "Tasks" do
  describe "GET /task/:id" do
    before do
      @user = User.create!(:email => 'joe@citizen.org', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')

      @app = App.create!(:name => 'Change your name')
      @married_form = @app.forms.create!(:call_to_action => 'Get Married!', :name => 'Getting Married Form', :url => 'http://example.gov/married.pdf')
      @divorced_form = @app.forms.create!(:call_to_action => 'Get Divorced!', :name => 'Getting Divorced Form', :url => 'http://example.gov/divorced.pdf')
      @married_form.criteria << @app.criteria.create!(:label => 'Getting Married')
      @divorced_form.criteria << @app.criteria.create!(:label => 'Getting Divorced')
      @married_pdf = Pdf.create!(:name => 'Form 123 - Getting Married', :url => 'http://example.gov/married.pdf', :form_id => @married_form.id)
      @divorced_pdf = Pdf.create!(:name => 'Form 789 - Getting Divorced', :url => 'http://example.gov/divorced.pdf', :form_id => @divorced_form.id)
      
      @user.tasks.create!(:app_id => @app.id)
      @user.tasks.first.task_items.create!(:form_id => @married_form.id)
      @user.tasks.first.task_items.create!(:form_id => @divorced_form.id)
      @task = @user.tasks.first
      create_logged_in_user(@user)
      visit task_path(@task)
    end
    
    it "should display a task with links to download pdfs" do
      page.should have_content(@task.app.name)
      @task.task_items.each{|task_item| page.should have_content(task_item.form.call_to_action) }
      page.should have_content "0 of 2 items complete."
      page.should have_link "Download Pre-filled PDF form"
    end
    
    it "should let a user mark all items as complete" do
      click_button 'Mark All Items Complete'
      page.should have_content 'Dashboard'
      visit task_path(@task)
      page.should have_content "2 of 2 items complete."
      page.should have_content "Task completed at"
      page.should have_content "Item completed at"
      page.should have_no_button "Mark All Items Complete"
      page.should have_no_button "Mark Complete"
      page.should have_no_link "Download Pre-filled PDF form"
    end
    
    it "should let a user mark an individual task item as complete" do
      click_button 'Mark Complete'
      page.should have_content "1 of 2 items complete."
      page.should have_button "Mark All Items Complete"
      page.should have_no_content "Task completed at"
      page.should have_content "Item completed at"
      page.should have_button "Mark Complete"
      page.should have_link "Download Pre-filled PDF form"
    end
    
    it "should let a user remove an individual task item" do
      click_button "Remove"
      page.should have_content "0 of 1 items complete."
    end
    
    it "should complete the task if the user completes all the items" do
      click_button "Mark Complete"
      click_button "Mark Complete"
      page.should have_content "2 of 2 items complete."
      page.should have_content "Task completed at"
      page.should have_content "Item completed at"
      page.should have_no_button "Mark All Items Complete"
      page.should have_no_button "Mark Complete"
      page.should have_no_button "Download Pre-filled PDF form"
    end
    
    it "should complete the task if the user removes all the items" do
      click_button "Remove"
      click_button "Remove"
      page.should have_content "0 of 0 items complete."
      page.should have_content "Task completed at"
      page.should have_no_content "Item completed at"
      page.should have_no_button "Mark All Items Complete"
      page.should have_no_button "Mark Complete"
      page.should have_no_button "Download Pre-filled PDF form"
    end
  end
end