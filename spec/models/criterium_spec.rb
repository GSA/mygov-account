require 'spec_helper'

describe Criterium do
  before do
    @valid_attributes = {
      :label => 'Getting married'
    }
  end
  
  it { should validate_presence_of :label }
  it { should belong_to :app }
  
  it "should create a new instance given valid attributes" do
    Criterium.create!(@valid_attributes)
    should validate_uniqueness_of(:label).scoped_to(:app_id)
  end
end
