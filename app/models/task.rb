class Task < ActiveRecord::Base
  belongs_to :user
  has_many :task_items
  attr_accessible :completed_at, :name, :task_items_attributes, :user_id
  accepts_nested_attributes_for :task_items
  
  validates_presence_of :name, :user_id
end
