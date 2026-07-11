# frozen_string_literal: true

require "rails_helper"

RSpec.describe Entitlements do
  let(:organization) { build(:organization) }
  let(:resolver) { described_class.for(organization) }

  it "defaults to premium-everything (the stub's dev posture)" do
    expect(resolver.limit_for(:members)).to eq(200)
    expect(resolver.allows?(:custom_theme)).to be(true)
  end

  describe "tier limits (master plan, enforced at the seam)" do
    it "caps basic at 15 members / 2 board owners with no premium features" do
      with_tier :basic do
        expect(resolver.limit_for(:members)).to eq(15)
        expect(resolver.limit_for(:board_owners)).to eq(2)
        expect(resolver.allows?(:custom_theme)).to be(false)
      end
    end

    it "caps premium at 200 members / 10 board owners" do
      with_tier :premium do
        expect(resolver.limit_for(:members)).to eq(200)
        expect(resolver.limit_for(:board_owners)).to eq(10)
      end
    end

    it "leaves enterprise unlimited" do
      with_tier :enterprise do
        expect(resolver.limit_for(:members)).to be_nil
        expect(resolver.within_limit?(:members, 10_000)).to be(true)
      end
    end
  end

  describe "#within_limit?" do
    it "allows counts up to the limit and rejects past it" do
      with_tier :basic do
        expect(resolver.within_limit?(:members, 15)).to be(true)
        expect(resolver.within_limit?(:members, 16)).to be(false)
      end
    end
  end

  describe ".warn_if_stub_in_production" do
    it "screams into the log when the stub would gate production" do
      logger = instance_double(ActiveSupport::Logger)
      allow(logger).to receive(:error)
      described_class.warn_if_stub_in_production(
        ActiveSupport::EnvironmentInquirer.new("production"), logger
      )
      expect(logger).to have_received(:error).with(/STUB/)
    end

    it "stays quiet everywhere else" do
      logger = instance_double(ActiveSupport::Logger)
      allow(logger).to receive(:error)
      described_class.warn_if_stub_in_production(
        ActiveSupport::EnvironmentInquirer.new("test"), logger
      )
      expect(logger).not_to have_received(:error)
    end
  end
end
