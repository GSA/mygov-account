# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :notification_setting do
    user_id 1
    app_id 1
    delivery_type "MyText"
    notification_type_id 1
  end
end
