FactoryGirl.define do
  factory :notification do
    subject 'Test Notification'
    received_at nil
    user_id FactoryGirl.create(:user).id
    identifier 'omg-app-notification'

    name 'Test task'
    user_id 12345

    factory :notification_with_delivery_types do
      after :create do |notification|
        notification.delivery_type << FactoryGirl.create(:delivery_type, name: "email", notification_id: notification.id)
        notification.delivery_type << FactoryGirl.create(:delivery_type, name: "text", notification_id: notification.id)
        notification.save
      end
    end

  end
end