require 'spec_helper'

describe AppActivityLog do
  it { should belong_to :app }
  it { should belong_to :user }
end
