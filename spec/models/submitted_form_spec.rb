require 'spec_helper'

describe SubmittedForm do
  it { should belong_to :user }
  it { should belong_to :app }
  it { should validate_presence_of :form_number }
  it { should validate_presence_of :data_url }
end
