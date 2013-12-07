FactoryGirl.define do
  factory :notification do
    subject 'Test Notification'
    received_at Time.now
    identifier 'omg-app-notification'
    user_id User.find_or_create_by_email('test@test.gov').id
    # user_id User.create!({email:'12345@1234.gov',password:'Blahpassword123'}).id

    factory :notification_with_delivery_types do
      after :create do |notification|
        notification.delivery_types << FactoryGirl.create(:delivery_type, name: "email", notification_id: notification.id)
        notification.delivery_types << FactoryGirl.create(:delivery_type, name: "text", notification_id: notification.id)
        notification.save
      end
    end

  end
end