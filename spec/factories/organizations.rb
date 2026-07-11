# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id           :uuid             not null, primary key
#  discarded_at :datetime
#  name         :string           not null
#  settings     :jsonb            not null
#  slug         :citext           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_organizations_on_slug  (slug) UNIQUE
#
FactoryBot.define do
  factory :organization do
    sequence(:name) { |n| "Org #{n}" }
    sequence(:slug) { |n| "org-#{n}" }
    settings { Organization::DEFAULT_SETTINGS }

    trait :discarded do
      discarded_at { Time.current }
    end

    # The persona orgs every later spec composes from (org plan_2).
    trait :with_owner do
      after(:create) do |organization|
        create(:membership, :owner, organization:)
      end
    end

    # owner + 2 board owners + 3 requesters — the full small office.
    trait :full do
      after(:create) do |organization|
        create(:membership, :owner, organization:)
        create_list(:membership, 2, :board_owner, organization:)
        create_list(:membership, 3, organization:)
      end
    end
  end

  factory :membership do
    organization
    user
    state { "active" }

    # require_tenant makes even Membership.new raise without a tenant
    # (default_scope seeds new-record attributes), and acts_as_tenant
    # clobbers organization_id from the ambient tenant on create — so both
    # build and save happen inside the record's own tenant.
    initialize_with do
      ActsAsTenant.with_tenant(attributes.fetch(:organization)) { Membership.new(**attributes) }
    end
    to_create do |membership|
      ActsAsTenant.with_tenant(membership.organization) { membership.save! }
    end

    trait :owner do
      owner { true }
    end

    trait :board_owner do
      board_owner { true }
    end

    trait :pending do
      state { "pending_approval" }
    end

    trait :deactivated do
      state { "deactivated" }
    end
  end
end
