class TaskItem < ActiveRecord::Base
  belongs_to :task
  belongs_to :form
  attr_accessible :completed_at, :form_id
  validates_presence_of :form_id
  validates_uniqueness_of :form_id, :scoped_to => :task_id
end
