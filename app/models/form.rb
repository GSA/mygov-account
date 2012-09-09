class Form < ActiveRecord::Base
  belongs_to :app
  has_and_belongs_to_many :criteria
  validates_presence_of :call_to_action, :name, :url
  validates_uniqueness_of :url, :scope => :app_id
  attr_accessible :call_to_action, :name, :url, :app_id, :criterium_ids
end
