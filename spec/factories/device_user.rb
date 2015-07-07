FactoryGirl.define do
  factory :device_user do
    name 'Test User 1'
    sequence(:username) {|n| "testuser#{n}"}
    password 'Password1'
    password_confirmation 'Password1'
    active true
  end
end
