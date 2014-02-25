class DeliveryType < ActiveRecord::Base
  attr_accessible :name, :notification_id
  validates_inclusion_of :name, :in => ['dashboard', 'email', 'text']
end
