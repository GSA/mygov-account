class Task < ActiveRecord::Base
  belongs_to :user
  belongs_to :app
  has_many :task_items, :dependent => :destroy
  attr_accessible :completed_at, :task_items_attributes, :user_id, :app_id, :name
  accepts_nested_attributes_for :task_items
  validates_presence_of :app_id, :user_id, :name
  
  scope :uncompleted, where('ISNULL(completed_at)')
  
  def complete!
    self.task_items.each{|task_item| task_item.complete!}
    self.update_attributes(:completed_at => Time.now) 
  end
  
  def completed?
    self.completed_at.nil? ? false : true
  end
end
