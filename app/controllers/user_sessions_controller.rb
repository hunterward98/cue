# frozen_string_literal: true

# "Your sessions" (auth plan_2): list every signed-in device, revoke one,
# or realize with mild horror that the office iPad is still logged in.
class UserSessionsController < InertiaController
  def index
    sessions = Current.user.sessions.active.order(last_active_at: :desc)

    render inertia: "sessions/index", props: {
      sessions: sessions.map { |session| session_props(session) }
    }
  end

  def destroy
    session_record = Current.user.sessions.find(params[:id])
    current = session_record == Current.session

    session_record.destroy
    AuthEvent.record!("logout", user: Current.user, request:, metadata: { revoked: params[:id], remote: !current })

    if current
      cookies.delete(:session_id)
      redirect_to new_session_path, notice: "Signed out. The cues will wait."
    else
      redirect_to user_sessions_path, notice: "That session is gone."
    end
  end

  private

  def session_props(session)
    {
      id: session.id,
      current: session == Current.session,
      ip_address: session.ip_address,
      user_agent: session.user_agent,
      last_active_at: session.last_active_at.iso8601
    }
  end
end
