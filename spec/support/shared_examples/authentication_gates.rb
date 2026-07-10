# frozen_string_literal: true

# The two access walls every protected route inherits (auth plan_2).
# Usage: it_behaves_like "a route requiring a verified user" with a
# `perform_request` let calling the route.
RSpec.shared_examples "a route requiring a verified user" do
  it "rejects the signed-out", :negative do
    perform_request
    expect(response).to redirect_to(new_session_path)
  end

  it "walls off unverified accounts to the verification screen", :negative do
    sign_in create(:user, :unverified)
    perform_request
    expect(response).to redirect_to(email_verification_path)
  end
end
