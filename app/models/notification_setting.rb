class NotificationSetting < ActiveRecord::Base
  attr_accessible :app_id, :delivery_type, :notification_type_id, :user_id
end
