FactoryGirl.define do
  factory :notification do
    subject 'Test Notification'
    received_at Time.now
    notification_type 'omg-app-notification'
    # NOTE: user_id can be assigned in your test like this:
    # @notification = FactoryGirl.build(:notification)
    # @notification.assign_attributes({:user_id => user.id}, as: :admin)

    factory :notification_with_delivery_types do
      after :create do |notification|
        notification.delivery_types << FactoryGirl.create(:delivery_type, name: "email", notification_id: notification.id)
        notification.delivery_types << FactoryGirl.create(:delivery_type, name: "text", notification_id: notification.id)
        notification.save
      end
    end

  end
end