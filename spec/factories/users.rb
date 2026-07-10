FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@example.com" }
    login_mode { "password" }
    password { "a-long-enough-password" }
    verified_at { Time.current }

    trait :unverified do
      verified_at { nil }
    end

    trait :passwordless do
      login_mode { "passwordless" }
      password { nil }
    end

    trait :staff do
      staff { true }
    end
  end

  factory :session do
    user
    ip_address { "203.0.113.7" }
    user_agent { "RSpec" }
  end

  factory :auth_event do
    action { "signup" }
    user
  end
end
