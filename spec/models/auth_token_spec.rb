# frozen_string_literal: true

require "rails_helper"

# == Schema Information
#
# Table name: auth_tokens
#
#  id             :uuid             not null, primary key
#  attempts_count :integer          default(0), not null
#  code_digest    :string           not null
#  consumed_at    :datetime
#  expires_at     :datetime         not null
#  purpose        :string           not null
#  token_digest   :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :uuid             not null
#
# Indexes
#
#  index_auth_tokens_on_token_digest         (token_digest) UNIQUE
#  index_auth_tokens_on_user_id              (user_id)
#  index_auth_tokens_on_user_id_and_purpose  (user_id,purpose)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
RSpec.describe AuthToken, type: :model do
  let(:user) { create(:user) }

  describe ".issue!" do
    it "stores only digests, never the secrets" do
      issued = described_class.issue!(user:, purpose: "email_verification")

      expect(issued.code).to match(/\A\d{6}\z/)
      expect(issued.token.code_digest).not_to include(issued.code)
      expect(issued.token.token_digest).not_to include(issued.link_token)
      expect(issued.token.expires_at).to be_within(1.minute).of(15.minutes.from_now)
    end

    it "invalidates outstanding tokens of the same purpose on re-issue" do
      stale = described_class.issue!(user:, purpose: "email_verification")
      described_class.issue!(user:, purpose: "email_verification")

      expect(described_class.redeem_code(user:, purpose: "email_verification", code: stale.code)).to be_nil
    end

    it "leaves other purposes untouched by re-issue" do
      reset = described_class.issue!(user:, purpose: "password_reset")
      described_class.issue!(user:, purpose: "email_verification")

      expect(described_class.redeem_link(purpose: "password_reset", link_token: reset.link_token)).to be_present
    end
  end

  describe ".redeem_code" do
    it "consumes a valid code exactly once" do
      issued = described_class.issue!(user:, purpose: "email_verification")

      expect(described_class.redeem_code(user:, purpose: "email_verification", code: issued.code)).to be_present
      expect(described_class.redeem_code(user:, purpose: "email_verification", code: issued.code)).to be_nil
    end

    it "rejects a wrong code and burns an attempt", :negative do
      issued = described_class.issue!(user:, purpose: "email_verification")

      expect(described_class.redeem_code(user:, purpose: "email_verification", code: "000000")).to be_nil
      expect(issued.token.reload.attempts_count).to eq(1)
    end

    it "burns the token after MAX_ATTEMPTS guesses, even a late correct one", :negative do
      issued = described_class.issue!(user:, purpose: "email_verification")

      AuthToken::MAX_ATTEMPTS.times do
        described_class.redeem_code(user:, purpose: "email_verification", code: "000000")
      end

      expect(described_class.redeem_code(user:, purpose: "email_verification", code: issued.code)).to be_nil
    end

    it "rejects an expired code", :negative do
      issued = described_class.issue!(user:, purpose: "email_verification")

      travel_to(16.minutes.from_now) do
        expect(described_class.redeem_code(user:, purpose: "email_verification", code: issued.code)).to be_nil
      end
    end

    it "rejects a code redeemed for a different purpose", :negative do
      issued = described_class.issue!(user:, purpose: "password_reset")

      expect(described_class.redeem_code(user:, purpose: "email_verification", code: issued.code)).to be_nil
    end

    it "rejects another user's code", :negative do
      issued = described_class.issue!(user: create(:user), purpose: "email_verification")

      expect(described_class.redeem_code(user:, purpose: "email_verification", code: issued.code)).to be_nil
    end
  end

  describe ".redeem_link" do
    it "consumes a valid link token exactly once" do
      issued = described_class.issue!(user:, purpose: "email_verification")

      expect(described_class.redeem_link(purpose: "email_verification", link_token: issued.link_token)).to be_present
      expect(described_class.redeem_link(purpose: "email_verification", link_token: issued.link_token)).to be_nil
    end

    it "rejects a link token replayed against another purpose", :negative do
      issued = described_class.issue!(user:, purpose: "password_reset")

      expect(described_class.redeem_link(purpose: "email_verification", link_token: issued.link_token)).to be_nil
    end

    it "rejects garbage link tokens", :negative do
      expect(described_class.redeem_link(purpose: "email_verification", link_token: "forged")).to be_nil
    end
  end

  it "gives second-factor codes the short 5-minute leash" do
    issued = described_class.issue!(user:, purpose: "second_factor")
    expect(issued.token.expires_at).to be_within(1.minute).of(5.minutes.from_now)
  end

  it "rejects unknown purposes at both layers", :negative do
    expect(build(:user).auth_tokens.build(purpose: "mystery")).not_to be_valid
    expect { described_class.issue!(user:, purpose: "mystery") }.to raise_error(KeyError)
  end
end
