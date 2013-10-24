FactoryGirl.define do
  factory :task_item do
    name 'My awesome task item'
    url 'somedomain.test/url'
    task_id 12345
  end
end