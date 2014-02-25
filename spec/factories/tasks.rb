FactoryGirl.define do
  factory :task do
    name 'Test task'
    user_id 12345
    app_id 678910

    factory :task_with_task_items do
      after :create do |task|
        task.task_items << FactoryGirl.create(:task_item, name: "Task 1", url: "task/item/id/url/1", task_id: task.id)
        task.task_items << FactoryGirl.create(:task_item, name: "Task 2", url: "task/item/id/url/2", task_id: task.id)
        task.save
      end
    end

  end
end