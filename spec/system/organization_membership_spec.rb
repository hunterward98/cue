# frozen_string_literal: true

require "rails_helper"

# The fork matrix org plan_3 asks for: {existing user, new user} x
# {invitation, join request} — four end-to-end doors into an org.
RSpec.describe "Getting into an org", type: :system do
  def latest_code
    ActionMailer::Base.deliveries.last.subject[/\d{6}/]
  end

  it "invitation + existing user: signs in mid-flow and lands in the org" do
    with_each_viewport do |viewport|
      organization = create(:organization, name: "Riverside #{viewport}", slug: "riverside-#{viewport}")
      owner = create(:membership, :owner, organization:).user
      invitee = create(:user, email_address: "invitee-#{viewport}@example.com", password: "a-long-enough-password")
      issued = ActsAsTenant.with_tenant(organization) do
        Invitation.invite!(organization:, inviter: owner, email: invitee.email_address)
      end

      visit accept_invitation_path(token: issued.token)
      expect(page).to have_css("h1", text: "Sign in")

      fill_in "Email", with: invitee.email_address
      fill_in "Password", with: "a-long-enough-password"
      click_button "Sign in"

      expect(page).to have_css("h1", text: organization.name)
      membership = ActsAsTenant.with_tenant(organization) { organization.memberships.find_by(user: invitee) }
      expect(membership).to be_active
    end
  end

  it "invitation + new user: signs up, skips verification, and lands in the org" do
    with_each_viewport do |viewport|
      organization = create(:organization, name: "Riverside #{viewport}", slug: "riverside-#{viewport}")
      owner = create(:membership, :owner, organization:).user
      email = "brandnew-#{viewport}@example.com"
      issued = ActsAsTenant.with_tenant(organization) do
        Invitation.invite!(organization:, inviter: owner, email:)
      end

      visit accept_invitation_path(token: issued.token)
      expect(page).to have_css("h1", text: "Create your account")
      expect(find_field("Email").value).to eq(email)

      fill_in "Password (12+ characters)", with: "a-long-enough-password"
      click_button "Create account"

      # Straight to the org — no "check your inbox" detour (ADR 0015).
      expect(page).to have_css("h1", text: organization.name)
      user = User.find_by!(email_address: email)
      expect(user).to be_verified
      membership = ActsAsTenant.with_tenant(organization) { organization.memberships.find_by(user:) }
      expect(membership).to be_active
    end
  end

  it "join request + existing user: signs in mid-flow, requests, and waits for approval" do
    with_each_viewport do |viewport|
      organization = create(:organization, name: "Riverside #{viewport}", slug: "riverside-#{viewport}")
      create(:membership, :owner, organization:)
      requester = create(:user, email_address: "joiner-#{viewport}@example.com", password: "a-long-enough-password")

      visit join_organization_path(org_slug: organization.slug)
      expect(page).to have_css("h1", text: "Sign in")

      fill_in "Email", with: requester.email_address
      fill_in "Password", with: "a-long-enough-password"
      click_button "Sign in"

      expect(page).to have_css("h1", text: "Join #{organization.name}")
      click_button "Request to join"

      expect(page).to have_css("h1", text: "Request sent to #{organization.name}")
      membership = ActsAsTenant.with_tenant(organization) { organization.memberships.find_by(user: requester) }
      expect(membership.state).to eq("pending_approval")
    end
  end

  it "join request + new user: signs up, verifies, and requests to join" do
    with_each_viewport do |viewport|
      organization = create(:organization, name: "Riverside #{viewport}", slug: "riverside-#{viewport}")
      create(:membership, :owner, organization:)
      email = "newjoiner-#{viewport}@example.com"

      visit join_organization_path(org_slug: organization.slug)
      expect(page).to have_css("h1", text: "Sign in")
      click_link "Create an account"

      fill_in "Email", with: email
      fill_in "Password (12+ characters)", with: "a-long-enough-password"
      click_button "Create account"

      expect(page).to have_css("h1", text: "Check your inbox")
      fill_in "Verification code", with: latest_code
      click_button "Verify"

      # Verification's own return-to lands back on the join page, not
      # the generic org switcher.
      expect(page).to have_css("h1", text: "Join #{organization.name}")
      click_button "Request to join"

      expect(page).to have_css("h1", text: "Request sent to #{organization.name}")
      user = User.find_by!(email_address: email)
      membership = ActsAsTenant.with_tenant(organization) { organization.memberships.find_by(user:) }
      expect(membership.state).to eq("pending_approval")
    end
  end
end
