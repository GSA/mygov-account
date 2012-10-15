class App < ActiveRecord::Base
  has_many :criteria, :dependent => :destroy
  has_many :forms, :dependent => :destroy
  validates_presence_of :name, :slug
  validates_uniqueness_of :slug
  before_validation :generate_slug

  attr_accessible :name, :action_phrase
    
  def to_param
    self.slug
  end
  
  def find_forms_by_criteria(criteria_list)
    self.forms.reject{|form| !form.valid_for_criteria(criteria_list) }
  end
  
  private
  
  def generate_slug
    self.slug = self.name.parameterize if self.name
  end
end
