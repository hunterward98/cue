# Idempotent development data: one demo org with the full persona cast
# (org plan_2). Production seeds nothing — orgs arrive through signup.
if Rails.env.development?
  demo = Organization.find_or_create_by!(slug: "demo") do |organization|
    organization.name = "Demo Office"
    organization.settings = Organization::DEFAULT_SETTINGS
  end

  people = {
    "owner@demo.test" => { owner: true },
    "boards-a@demo.test" => { board_owner: true },
    "boards-b@demo.test" => { board_owner: true },
    "requester@demo.test" => {}
  }

  ActsAsTenant.with_tenant(demo) do
    people.each do |email_address, roles|
      user = User.find_or_create_by!(email_address:) do |u|
        u.login_mode = "password"
        u.password = "a-long-enough-password"
        u.verified_at = Time.current
      end
      Membership.find_or_create_by!(organization: demo, user:) do |membership|
        membership.state = "active"
        membership.owner = roles.fetch(:owner, false)
        membership.board_owner = roles.fetch(:board_owner, false)
      end
    end
  end
end
