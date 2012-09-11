class Task < ActiveRecord::Base
  belongs_to :user
  belongs_to :app
  has_many :task_items, :dependent => :destroy
  attr_accessible :completed_at, :task_items_attributes, :user_id, :app_id
  accepts_nested_attributes_for :task_items
  validates_presence_of :app_id, :user_id
end
