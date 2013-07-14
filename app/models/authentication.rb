class Authentication < ActiveRecord::Base
  belongs_to :user
  attr_accessible :data, :provider, :uid, :user
  serialize :data, Hash
  validates_presence_of :provider, :uid
  validates_uniqueness_of :uid, :scope => [:provider]
end
