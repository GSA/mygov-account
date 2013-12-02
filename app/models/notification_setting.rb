class NotificationSetting < ActiveRecord::Base
  attr_accessible :delivery_type, :notification_type_id, :user_id
  belongs_to :user
  validates :delivery_type, uniqueness: { scope: :notification_type_id }
end
