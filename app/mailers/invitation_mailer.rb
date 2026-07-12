# frozen_string_literal: true

# Real delivery infra lands with notifications plan_2 (same letter_opener
# stopgap auth plan_2 already ships with).
class InvitationMailer < ApplicationMailer
  def invite(invitation, token:)
    @organization = invitation.organization
    @inviter = invitation.inviter
    @link = accept_invitation_url(token:)
    mail to: invitation.email, subject: "#{@inviter.email_address} invited you to #{@organization.name} on Cue"
  end
end
