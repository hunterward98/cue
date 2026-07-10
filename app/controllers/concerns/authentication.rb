# frozen_string_literal: true

# Session resumption + the two access gates (auth plan_2): every route
# requires an authenticated AND verified user unless it explicitly opts
# out. Unverified accounts can do nothing but the verification flow.
module Authentication
  extend ActiveSupport::Concern

  included do
    # Resumption is unconditional — even opted-out screens (login, health)
    # need to know who's asking. Only the two gates are skippable.
    before_action :resume_session
    before_action :require_authentication
    before_action :require_verification
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
      skip_before_action :require_verification, **options
    end

    # For the verification flow itself: needs a session, tolerates the
    # unverified state.
    def allow_unverified_access(**options)
      skip_before_action :require_verification, **options
    end
  end

  private

  def authenticated? = resume_session.present?

  def require_authentication
    Current.session || request_authentication
  end

  def require_verification
    return if Current.user.nil? || Current.user.verified?

    redirect_to email_verification_path
  end

  def resume_session
    Current.session ||= find_session_by_cookie
  end

  def find_session_by_cookie
    session_record = Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
    return nil unless session_record

    if session_record.expired?
      session_record.destroy
      cookies.delete(:session_id)
      return nil
    end

    session_record.record_activity!
    session_record
  end

  def request_authentication
    session[:return_to_after_authenticating] = request.url
    redirect_to new_session_path
  end

  def after_authentication_url
    session.delete(:return_to_after_authenticating) || root_url
  end

  def start_new_session_for(user)
    # Rotate the Rails session on privilege change (fixation defense);
    # keep only the post-login destination.
    return_to = session[:return_to_after_authenticating]
    reset_session
    session[:return_to_after_authenticating] = return_to if return_to

    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |user_session|
      Current.session = user_session
      # Deliberately no client-side expiry: the server's absolute 7-day
      # check in find_session_by_cookie is the single enforcer (and stays
      # testable — an expired cookie the browser withholds can't be).
      cookies.signed.permanent[:session_id] = {
        value: user_session.id,
        httponly: true,
        same_site: :lax
      }
    end
  end

  def terminate_session
    Current.session.destroy
    cookies.delete(:session_id)
  end
end
