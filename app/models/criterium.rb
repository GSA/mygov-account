class Criterium < ActiveRecord::Base
  belongs_to :app
  has_and_belongs_to_many :forms
  validates_presence_of :label
  validates_uniqueness_of :label, :scope => :app_id
  attr_accessible :label, :app_id
end
