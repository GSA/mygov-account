require 'spec_helper'

describe "HomePage" do
  before do
    @user = User.create!(:email => 'joe@citizen.org', :password => 'random', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen', :is_approved => true)
  end
  
  describe "GET /" do
    context "when not logged in" do
      it "should prompt the user to login" do
        visit root_path
        page.should have_content("Sign in")
      end
    end
    
    context "when already logged in" do
      before do
        create_logged_in_user(@user)
      end
      
      it "should show the user the dashboard" do
        visit root_path
        page.should have_content "MyGov Dashboard"
        click_link 'Joe Citizen'
        page.should have_content 'Your MyGov Profile'
      end
      
      context "when the user has tasks with task items" do
        before do
          @app = App.create!(:name => 'Change your name')
          @married_form = @app.forms.create!(:call_to_action => 'Get Married!', :name => 'Getting Married Form', :url => 'http://example.gov/married.pdf')
          @divorced_form = @app.forms.create!(:call_to_action => 'Get Divorced!', :name => 'Getting Divorced Form', :url => 'http://example.gov/divorced.pdf')
          @married_form.criteria << @app.criteria.create!(:label => 'Getting Married')
          @divorced_form.criteria << @app.criteria.create!(:label => 'Getting Divorced')
          
          @user.tasks.create!(:app_id => @app.id)
          @user.tasks.first.task_items.create!(:form_id => @married_form.id)
          @user.tasks.first.task_items.create!(:form_id => @divorced_form.id)
        end
        
        it "should show the tasks on the dashboard and allow the user to remove tasks" do
          visit root_path
          page.should have_content "MyGov Dashboard"
          page.should have_content "You're almost done #{@user.tasks.first.app.name}!"
          page.should have_content "Get Married!"
          page.should have_content "Get Divorced!"
          click_link "x Remove"
          page.should have_content "You're almost done #{@user.tasks.first.app.name}!"
          page.should_not have_content "Get Married!"
          page.should have_content "Get Divorced!"
          click_link "x Remove"
          page.should have_content "MyGov Dashboard"
          page.should_not have_content "You're almost done #{@user.tasks.first.app.name}!"
          page.should_not have_content "Get Married!"
          page.should_not have_content "Get Divorced!"
        end
      end
    
      context "when it is a US Holiday" do
        before do
          UsHoliday.create!(:name => "Pretend US Holiday", :observed_on => Date.current, :uid => 'pretend-us-holiday')
        end
        
        it "should show a US holiday notice on the dashboard sidebar" do
          visit root_path
          page.should have_content "Today is Pretend US Holiday"
        end
      end
      
      context "when historical events occured on that day in the past" do
        before do
          UsHistoricalEvent.create!(:summary => 'Pretend Historical Event', :uid => 'pretend-historical-event', :day => Date.current.day, :month => Date.current.month, :description => 'Something historical happened today.')
        end
        
        it "should show the event summary and description on the dashboard sidebar" do
          visit root_path
          page.should have_content "Pretend Historical Event - Something historical happened today."
        end
      end
    end
  end
end