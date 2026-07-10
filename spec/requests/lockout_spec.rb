# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Account lockout", type: :request do
  let(:user) { create(:user, email_address: "target@example.com") }

  def failed_attempt
    post session_path, params: { email_address: user.email_address, password: "wrong-but-long-enough" }
  end

  it "locks after ten straight failures and emails the unlock link" do
    perform_enqueued_jobs { 10.times { failed_attempt } }

    expect(user.reload).to be_locked
    expect(ActionMailer::Base.deliveries.map(&:subject)).to include("Your Cue account is locked")
    expect(AuthEvent.where(action: "account_locked", user:)).to exist
  end

  it "rejects the correct password on a locked account with the identical alert", :negative do
    user.update!(locked_at: Time.current)

    post session_path, params: { email_address: user.email_address, password: "a-long-enough-password" }

    expect(user.sessions.count).to eq(0)
    expect(flash[:alert]).to eq(SessionsController::INVALID_LOGIN)
  end

  it "resets the failure count on a successful login" do
    3.times { failed_attempt }
    expect(user.reload.failed_login_attempts).to eq(3)

    sign_in user
    expect(user.reload.failed_login_attempts).to eq(0)
  end

  it "unlocks via the emailed link, once", :negative do
    user.update!(locked_at: Time.current, failed_login_attempts: 10)
    issued = AuthToken.issue!(user:, purpose: "unlock")

    get unlock_path(token: issued.link_token)
    expect(user.reload).not_to be_locked
    expect(AuthEvent.where(action: "account_unlocked", user:)).to exist

    user.update!(locked_at: Time.current)
    get unlock_path(token: issued.link_token)
    expect(user.reload).to be_locked
    expect(flash[:alert]).to include("invalid or has expired")
  end

  it "does not send a second unlock email while already locked", :negative do
    user.update!(locked_at: Time.current, failed_login_attempts: 10)

    perform_enqueued_jobs { 2.times { failed_attempt } }

    expect(ActionMailer::Base.deliveries.map(&:subject)).not_to include("Your Cue account is locked")
  end
end
