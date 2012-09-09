class Criterium < ActiveRecord::Base
  attr_accessible :label, :app_id
  belongs_to :app
  validates_presence_of :label
  validates_uniqueness_of :label, :scope => :app_id
end
