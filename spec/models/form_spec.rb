require 'spec_helper'

describe Form do
  before do
    @valid_attributes = {
      :url => 'http://www.socialsecurity.gov/online/ss-5.pdf',
      :name => 'Application for a Social Security Card',
      :call_to_action => 'Change your name with Social Security'
    }
  end
  
  it { should belong_to :app }
  it { should validate_presence_of :url }
  it { should validate_presence_of :name }
  it { should validate_presence_of :call_to_action }
  
  it "should create a new instance given valid attributes" do
    Form.create!(@valid_attributes)
    should validate_uniqueness_of(:url).scoped_to(:app_id)
  end
end
