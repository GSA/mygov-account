# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :notification_setting do
    user_id 1
    delivery_type "text"
    notification_type_id "my-app"
  end
end
