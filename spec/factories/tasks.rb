FactoryGirl.define do
  factory :task do
    name 'Test task'
    user_id User.first.id

    app_id App.first.id || App.create(
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