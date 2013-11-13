FactoryGirl.define do
  factory :task do
    name 'Test task'
    # @user = User.count>0 ? User.first.id : User.create(
    #     :email => 'test@test.gov',
    #     :password => '1a2B3cPassword'
    #   )
    # @user.confirm!

    user_id 12345

    app_id App.create(
            name: 'TestApp',
            description: 'A description for our test app',
            short_description: 'Short test description',
            url: 'another/test/url'
            ).id

    factory :task_with_task_items do
      after :create do |task|
        task.task_items << FactoryGirl.create(:task_item, name: "Task 1", url: "task/item/id/url/1", task_id: task.id)
        task.task_items << FactoryGirl.create(:task_item, name: "Task 2", url: "task/item/id/url/2", task_id: task.id)
        task.save
      end
    end

  end
end