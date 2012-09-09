class App < ActiveRecord::Base
  has_many :criteria, :dependent => :destroy
  has_many :forms, :dependent => :destroy
  validates_presence_of :name, :slug
  validates_uniqueness_of :slug
  before_validation :generate_slug

  attr_accessible :name
    
  def to_param
    self.slug
  end
  
  private
  
  def generate_slug
    self.slug = self.name.parameterize if self.name
  end
end
