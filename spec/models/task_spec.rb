require 'spec_helper'

describe Task do
  before do
    @user = User.create!(:email => 'joe@citizen.org', :first_name => 'Joe', :last_name => 'Citizen', :name => 'Joe Citizen')
    @app = App.create!(:name => 'Test App')
    @valid_attributes = {
      :user_id => @user.id,
      :app_id => @app.id
    }
  end
  
  it { should validate_presence_of :app_id }
  it { should validate_presence_of :user_id }
  it { should belong_to :user }
  it { should belong_to :app }
  
  it "should create a new instance given valid attributes" do
    Task.create!(@valid_attributes)
  end
end
