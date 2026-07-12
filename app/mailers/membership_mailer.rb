# frozen_string_literal: true

# org plan_3, completing the handoff Memberships::Deny's plan_2 comment
# left open. Real delivery infra lands with notifications plan_2 (same
# letter_opener stopgap the rest of the app uses meanwhile).
class MembershipMailer < ApplicationMailer
  # Genuinely neutral (plan_3 critique): the requester asked to join by
  # name, so naming the org back isn't a leak, but nothing here explains
  # *why* — that's an owner conversation, not an automated one.
  def join_request_denied(user, organization)
    @organization_name = organization.name
    mail to: user.email_address, subject: "Your request to join #{organization.name}"
  end
end
