class App < ActiveRecord::Base
  attr_accessible :name
  validates_presence_of :name, :slug
  validates_uniqueness_of :slug
  before_validation :generate_slug
  
  has_many :criteria, :dependent => :destroy
  
  def to_param
    self.slug
  end
  
  private
  
  def generate_slug
    self.slug = self.name.parameterize if self.name
  end
end
