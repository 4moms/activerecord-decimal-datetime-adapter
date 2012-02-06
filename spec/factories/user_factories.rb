FactoryGirl.define do
  factory :user do
    sequence(:login) { |n| "user#{n}" }
  end
end
