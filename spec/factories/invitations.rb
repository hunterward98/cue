# frozen_string_literal: true

# == Schema Information
#
# Table name: invitations
#
#  id              :uuid             not null, primary key
#  board_owner     :boolean          default(FALSE), not null
#  email           :citext           not null
#  expires_at      :datetime         not null
#  owner           :boolean          default(FALSE), not null
#  state           :string           default("pending"), not null
#  token_digest    :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  inviter_id      :uuid             not null
#  organization_id :uuid             not null
#
FactoryBot.define do
  factory :invitation do
    organization
    inviter factory: :user
    sequence(:email) { |n| "invitee#{n}@example.com" }
    token_digest { Invitation.digest(SecureRandom.urlsafe_base64(32)) }
    expires_at { Invitation::TTL.from_now }
    state { "pending" }

    initialize_with do
      ActsAsTenant.with_tenant(attributes.fetch(:organization)) { Invitation.new(**attributes) }
    end
    to_create do |invitation|
      ActsAsTenant.with_tenant(invitation.organization) { invitation.save! }
    end

    trait :owner do
      owner { true }
    end

    trait :board_owner do
      board_owner { true }
    end

    trait :accepted do
      state { "accepted" }
    end

    trait :revoked do
      state { "revoked" }
    end

    trait :expired do
      state { "expired" }
      expires_at { 1.day.ago }
    end
  end
end
