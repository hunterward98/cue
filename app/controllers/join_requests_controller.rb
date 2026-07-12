# frozen_string_literal: true

# The request-to-join door (org plan_3): a shared link, not a personal
# invitation — lands in the org's approval queue instead of granting
# membership outright. Unlike InvitationAcceptancesController this never
# 404s on a bad token (there's no token) — a disabled or unknown slug
# just renders the same "not available" outcome either way, so it can't
# be used to probe which org slugs exist.
class JoinRequestsController < InertiaController
  allow_unauthenticated_access

  def show
    organization = joinable_organization
    return render_unavailable unless organization

    if Current.user
      render_form(organization)
    else
      session[:pending_join_slug] = organization.slug
      redirect_to new_session_path, notice: "Sign in to request access to #{organization.name}."
    end
  end

  def create
    organization = joinable_organization
    return render_unavailable unless organization
    return redirect_to new_session_path unless Current.user

    if existing_membership(organization)
      return redirect_to join_organization_path(org_slug: organization.slug)
    end

    result = Memberships::Enroll.call(organization:, user: Current.user, state: "pending_approval")
    if result.success?
      redirect_to join_organization_path(org_slug: organization.slug),
                  notice: "Request sent — an owner will review it."
    else
      redirect_to join_organization_path(org_slug: organization.slug), alert: result.error
    end
  end

  private

  def joinable_organization
    organization = Organization.kept.find_by(slug: params[:org_slug])
    return nil unless organization
    return nil unless ActiveModel::Type::Boolean.new.cast(organization.setting("join_link_enabled"))

    organization
  end

  def existing_membership(organization)
    ActsAsTenant.without_tenant { organization.memberships.find_by(user: Current.user) }
  end

  def render_form(organization)
    membership = existing_membership(organization)
    return redirect_to org_root_path(org_slug: organization.slug) if membership&.active?

    render inertia: "org/join", props: {
      organization: { name: organization.name, slug: organization.slug },
      status: membership&.state || "none"
    }
  end

  def render_unavailable
    redirect_to root_path, alert: "That join link isn't available."
  end
end
