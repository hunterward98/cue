# frozen_string_literal: true

# Every auth email in one place (auth plan_2). Codes always ship with a
# magic-link twin: code for cross-device typing, link for the one-tap
# phone case. Real delivery infra lands with notifications plan_2.
class AuthMailer < ApplicationMailer
  def email_verification(user, code:, link_token:)
    @code = code
    @link = confirm_email_verification_url(token: link_token)
    mail to: user.email_address, subject: "Your Cue verification code: #{code}"
  end

  # Sent when someone signs up with an email that already has an account —
  # the signup screen must not reveal that (enumeration defense).
  def existing_account(user)
    @email = user.email_address
    mail to: user.email_address, subject: "You already have a Cue account"
  end

  def login_code(user, code:, link_token:)
    @code = code
    @link = confirm_login_code_url(token: link_token)
    mail to: user.email_address, subject: "Your Cue sign-in code: #{code}"
  end

  # Sent when a password-mode account requests a login code — the request
  # screen must not reveal the account's mode.
  def password_login_reminder(user)
    mail to: user.email_address, subject: "Your Cue account signs in with a password"
  end

  def password_reset(user, link_token:)
    @link = edit_password_url(token: link_token)
    mail to: user.email_address, subject: "Reset your Cue password"
  end

  def account_locked(user, link_token:)
    @link = unlock_url(token: link_token)
    mail to: user.email_address, subject: "Your Cue account is locked"
  end

  def password_changed(user)
    mail to: user.email_address, subject: "Your Cue password was changed"
  end
end
