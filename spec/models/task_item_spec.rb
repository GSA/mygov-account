require 'spec_helper'

describe TaskItem do
  before do
    @user = User.create!(:email => 'joe@citizen.org', :password => 'random', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
    @app= App.create!(:name => 'Test App')
    @app.forms.create!(:call_to_action => 'Buy a car', :name => 'Car buying', :url => 'http://example.gov/form.pdf')
    @task = Task.new(:app_id => @app)
    @task.user = @user
    @task.save!
    @valid_attributes = {
      :form_id => @app.forms.first.id,
      :task_id => @task_id
    }
  end
  
  it { should belong_to :task }
  it { should belong_to :form }
  it { should validate_presence_of :form_id }
  
  it "should create a new instance given valid attributes" do
    TaskItem.create!(@valid_attributes)
    should validate_uniqueness_of(:form_id).scoped_to(:task_id)
  end
  
  describe "#completed?" do
    it "should return true if completed_at is not nil" do
      TaskItem.new(:completed_at => Time.now).completed?.should be_true
    end
    
    it "should return false if completed_at is nil" do
      TaskItem.new.completed?.should be_false
    end
  end
end