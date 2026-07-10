# frozen_string_literal: true

require "rails_helper"

RSpec.describe PasswordBreachCheck do
  include WebMock::API

  let(:password) { "a-long-enough-password" }
  let(:digest) { OpenSSL::Digest::SHA1.hexdigest(password).upcase }
  let(:range_url) { "https://api.pwnedpasswords.com/range/#{digest[0, 5]}" }

  around do |example|
    WebMock.enable!
    WebMock.disable_net_connect!(allow_localhost: true)
    example.run
  ensure
    WebMock.reset!
    WebMock.disable!
  end

  it "flags a breached password", :negative do
    stub_request(:get, range_url).to_return(status: 200, body: "#{digest[5..]}:1337\nAAAA:1\n")

    expect(described_class.breached?(password)).to be(true)
  end

  it "clears a password absent from the range" do
    stub_request(:get, range_url).to_return(status: 200, body: "AAAA:1\nBBBB:2\n")

    expect(described_class.breached?(password)).to be(false)
  end

  it "fails open on timeouts, logging a warning" do
    stub_request(:get, range_url).to_timeout
    allow(Rails.logger).to receive(:warn)

    expect(described_class.breached?(password)).to be(false)
    expect(Rails.logger).to have_received(:warn).with(/failing open/)
  end

  it "fails open on API errors" do
    stub_request(:get, range_url).to_return(status: 503)

    expect(described_class.breached?(password)).to be(false)
  end

  it "accepts an unbreached password at the model when enabled" do
    stub_request(:get, range_url).to_return(status: 200, body: "AAAA:1\n")
    allow(Rails.configuration.x).to receive(:password_breach_check).and_return(true)

    expect(build(:user, password:)).to be_valid
  end

  it "rejects a breached password at the model when enabled", :negative do
    stub_request(:get, range_url).to_return(status: 200, body: "#{digest[5..]}:1337\n")
    allow(Rails.configuration.x).to receive(:password_breach_check).and_return(true)

    user = build(:user, password:)

    expect(user).not_to be_valid
    expect(user.errors[:password].sole).to include("public data breach")
  end
end
