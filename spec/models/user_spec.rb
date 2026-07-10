# frozen_string_literal: true

require "rails_helper"

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
RSpec.describe User, type: :model do
  it "has a valid factory (both modes)" do
    expect(build(:user)).to be_valid
    expect(build(:user, :passwordless)).to be_valid
  end

  it "normalizes email addresses" do
    user = create(:user, email_address: "  Mixed@Case.COM ")
    expect(user.email_address).to eq("mixed@case.com")
  end

  it { is_expected.to validate_inclusion_of(:login_mode).in_array(User::LOGIN_MODES) }

  it "rejects duplicate emails differing only by case", :negative do
    create(:user, email_address: "same@example.com")
    dupe = build(:user, email_address: "SAME@example.com")
    expect(dupe).not_to be_valid
    expect { dupe.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "rejects malformed emails", :negative do
    expect(build(:user, email_address: "not-an-email")).not_to be_valid
  end

  it "rejects password-mode signup without a password", :negative do
    expect(build(:user, password: nil)).not_to be_valid
  end

  it "rejects short and over-long passwords", :negative do
    expect(build(:user, password: "short")).not_to be_valid
    expect(build(:user, password: "x" * 73)).not_to be_valid
  end

  it "forbids a stored digest on passwordless accounts", :negative do
    sneaky = build(:user, :passwordless, password: "a-long-enough-password")
    expect(sneaky).not_to be_valid
  end

  it "rejects login modes outside the two ratified choices at the DB layer", :negative do
    expect { create(:user).update_column(:login_mode, "carrier-pigeon") }
      .to raise_error(ActiveRecord::StatementInvalid, /login_mode_check/)
  end

  describe "#verify!" do
    it "stamps verified_at once and keeps the original stamp" do
      user = create(:user, :unverified)
      expect { user.verify! }.to change(user, :verified?).from(false).to(true)

      travel_to(1.hour.from_now) do
        expect { user.verify! }.not_to change(user, :verified_at)
      end
    end
  end
end
