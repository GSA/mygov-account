class TaskItem < ActiveRecord::Base
  belongs_to :task
  belongs_to :form
  attr_accessible :completed_at, :form_id, :task_id
  validates_presence_of :form_id
  validates_uniqueness_of :form_id, :scope => :task_id
  
  scope :uncompleted, where('ISNULL(completed_at)')
  scope :completed, where('NOT ISNULL(completed_at)')
  
  def completed?
    self.completed_at.nil? ? false : true
  end
end
