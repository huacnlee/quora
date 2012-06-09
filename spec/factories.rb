FactoryGirl.define do
  factory :user do
    sequence(:email){|n| "foo#{n}@bar.com"}
    sequence(:name){|n| "u#{n}"}
    password 'really_really_dark'
  end
  
  factory :topic do
    sequence(:name){|n| "topic#{n}"}
  end
  
  factory :ask do
    user
    current_user_id{user.id}
    sequence(:title){|n| "ask_#{n}"}
  end
  
  factory :answer do
    ask
    user
    sequence(:body){|n| "blah #{n} blah blah #{n}..."}
  end
  
  factory :ask_log_ADD_TOPIC,class:AskLog do
    ask
    user
    title {FactoryGirl.create_list(:topic,3).collect(&:name).join(',')}
    target_id  {ask.id}
    action 'ADD_TOPIC'
    target_parent_id {ask.id}
    target_parent_title {ask.title}
    diff ""
  end
end