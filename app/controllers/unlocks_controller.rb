# frozen_string_literal: true

# Lockout recovery (auth plan_3): ten straight failures lock the account
# and email an unlock link; only the inbox owner can turn the key.
class UnlocksController < InertiaController
  allow_unauthenticated_access

  def show
    token = AuthToken.redeem_link(purpose: "unlock", link_token: params[:token])

    if token
      token.user.unlock!
      AuthEvent.record!("account_unlocked", user: token.user, request:)
      redirect_to new_session_path, notice: "Account unlocked. Try signing in again — gently, this time."
    else
      redirect_to new_session_path, alert: "That unlock link is invalid or has expired."
    end
  end
end
