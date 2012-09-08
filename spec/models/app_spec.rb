require 'spec_helper'

describe App do
  before do
    @valid_attributes = {
      :name => 'Change your name'
    }
  end
  
  it { should validate_presence_of :name }
  it { should validate_presence_of :slug }
  
  it "should create a new app with valid attributes, and generate a unique slug" do
    app = App.create!(@valid_attributes)
    app.slug.should == app.name.parameterize
  end
end
