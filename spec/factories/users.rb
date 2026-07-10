# == Schema Information
#
# Table name: users
#
#  id                    :uuid             not null, primary key
#  email_address         :citext           not null
#  failed_login_attempts :integer          default(0), not null
#  locked_at             :datetime
#  login_mode            :string           default("password"), not null
#  password_digest       :string
#  staff                 :boolean          default(FALSE), not null
#  verified_at           :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_users_on_email_address  (email_address) UNIQUE
#
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
