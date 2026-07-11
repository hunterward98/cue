# frozen_string_literal: true

require "rails_helper"

# == Schema Information
#
# Table name: memberships
#
#  id              :uuid             not null, primary key
#  board_owner     :boolean          default(FALSE), not null
#  owner           :boolean          default(FALSE), not null
#  state           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid             not null
#  user_id         :uuid             not null
#
# Indexes
#
#  index_memberships_on_organization_id              (organization_id)
#  index_memberships_on_organization_id_and_user_id  (organization_id,user_id) UNIQUE
#  index_memberships_on_user_id                      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (user_id => users.id)
#
RSpec.describe Membership, type: :model do
  let(:organization) { create(:organization) }

  def in_org(&)
    ActsAsTenant.with_tenant(organization, &)
  end

  it "has a valid factory" do
    expect(create(:membership, organization:)).to be_persisted
  end

  describe "uniqueness per org" do
    it "rejects a duplicate membership at the model layer", :negative do
      existing = create(:membership, organization:)
      duplicate = build(:membership, organization:, user: existing.user)
      in_org do
        expect(duplicate).not_to be_valid
      end
    end

    it "rejects a duplicate membership at the DB layer", :negative do
      existing = create(:membership, organization:)
      expect do
        in_org do
          duplicate = described_class.new(organization:, user: existing.user, state: "active")
          duplicate.save!(validate: false)
        end
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "states" do
    it "rejects states outside the machine", :negative do
      membership = build(:membership, organization:, state: "invited")
      in_org { expect(membership).not_to be_valid }
    end

    it "walks the allowed transitions" do
      membership = create(:membership, :pending, organization:)
      in_org do
        expect { membership.activate! }.to change(membership, :state).to("active")
        expect { membership.deactivate! }.to change(membership, :state).to("deactivated")
        expect { membership.activate! }.to change(membership, :state).to("active")
      end
    end

    it "rejects transitions the machine doesn't allow", :negative do
      pending_membership = create(:membership, :pending, organization:)
      active_membership = create(:membership, organization:)
      in_org do
        expect { pending_membership.deactivate! }.to raise_error(ActiveRecord::RecordInvalid, /can't go from/)
        expect { active_membership.update!(state: "pending_approval") }
          .to raise_error(ActiveRecord::RecordInvalid, /can't go from/)
      end
    end
  end

  describe "the last active owner" do
    it "cannot be deactivated", :negative do
      owner = create(:membership, :owner, organization:)
      in_org do
        expect { owner.deactivate! }
          .to raise_error(ActiveRecord::RecordInvalid, /at least one active owner/)
      end
    end

    it "cannot lose the owner flag", :negative do
      owner = create(:membership, :owner, organization:)
      in_org do
        expect { owner.update!(owner: false) }
          .to raise_error(ActiveRecord::RecordInvalid, /at least one active owner/)
      end
    end

    it "cannot be destroyed", :negative do
      owner = create(:membership, :owner, organization:)
      in_org do
        expect(owner.destroy).to be(false)
        expect(owner.errors[:base].join).to include("at least one active owner")
      end
    end

    it "steps down freely once another active owner exists (multiple owners are fine)" do
      owner = create(:membership, :owner, organization:)
      create(:membership, :owner, organization:)
      in_org do
        expect { owner.update!(owner: false) }.not_to raise_error
      end
    end

    it "lets non-owners, spare owners, and already-deactivated owners leave" do
      create(:membership, :owner, organization:)
      spare_owner = create(:membership, :owner, organization:)
      requester = create(:membership, organization:)
      deactivated_owner = create(:membership, :deactivated, organization:, owner: true)
      in_org do
        expect(requester.destroy).to be_truthy
        expect(spare_owner.destroy).to be_truthy
        expect(deactivated_owner.destroy).to be_truthy
      end
    end
  end

  describe "roles as booleans (plan_2 critique, ratified)" do
    it "answers requester? when neither flag is set" do
      expect(build(:membership).requester?).to be(true)
      expect(build(:membership, :owner).requester?).to be(false)
      expect(build(:membership, :board_owner).requester?).to be(false)
    end

    it "carries no role column that could ever encode a support/staff value", :negative do
      # Support is a global User flag (support-admin plan), structurally
      # inexpressible as a membership: no enum, no role string, nothing.
      expect(described_class.column_names).not_to include("role", "staff", "support")
    end

    it "scopes owners and board_owners to active rows only" do
      owner = create(:membership, :owner, organization:)
      board_owner = create(:membership, :board_owner, organization:)
      create(:membership, :deactivated, organization:, board_owner: true)

      in_org do
        expect(described_class.owners).to contain_exactly(owner)
        expect(described_class.board_owners).to contain_exactly(board_owner)
      end
    end
  end

  describe "tenancy (ADR 0010)" do
    it "scopes every query to the current tenant" do
      ours = create(:membership, organization:)
      other_org = create(:organization)
      create(:membership, organization: other_org)

      in_org do
        expect(described_class.all).to contain_exactly(ours)
      end
    end

    it "refuses tenant-model queries when no tenant is set", :negative do
      expect { described_class.count }.to raise_error(ActsAsTenant::Errors::NoTenantSet)
    end
  end
end
