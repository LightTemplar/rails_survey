FactoryBot.define do
  factory :user do
    email { 'user@example.com' }
    password { 'Password1' }
    password_confirmation { 'Password1' }
    id { 0 }
    # roles [FactoryBot.create(:role)]
  end
end
