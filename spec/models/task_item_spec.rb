require 'spec_helper'

describe TaskItem do
  before do
    create_approved_beta_signup('joe@citizen.org')
    @user = User.create!(:email => 'joe@citizen.org', :password => 'Password1')
    @app= App.create!(:name => 'Test App', :redirect_uri => "http://localhost:3000/")
    @task = Task.create!({:name => 'Test task', :app => @app, :user => @user}, :as => :admin)
    @valid_attributes = {
      :name => 'Task Item 1',
      :url => 'http://example.gov/task'    
    }
  end
  
  it { should belong_to :task }
  
  it "should create a new instance given valid attributes" do
    task_item = TaskItem.new(@valid_attributes)
    task_item.task_id = @task.id
    task_item.save!
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