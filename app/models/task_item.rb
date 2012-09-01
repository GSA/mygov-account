class TaskItem < ActiveRecord::Base
  belongs_to :task
  attr_accessible :completed_at, :name, :url
  validates_presence_of :name, :url
  validates_uniqueness_of :url, :scoped_to => :task_id
end
