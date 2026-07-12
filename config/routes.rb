Rails.application.routes.draw do
  # Cheap liveness probe (200 if the app boots) for load balancers.
  get "up" => "rails/health#show", as: :rails_health_check

  # Deep health check proving Rails → Inertia → React → Tailwind → DB
  # (foundation plan_2). Returns 503 if any layer fails.
  get "up/full" => "health#full", as: :full_health_check

  resource :registration, only: %i[new create]

  # Verification gate: show = "check your inbox" (code entry), update =
  # submit code, resend = re-issue, confirm = magic-link tap from email.
  resource :email_verification, only: %i[show update] do
    post :resend
  end
  get "email_verification/:token" => "email_verifications#confirm",
      as: :confirm_email_verification

  resource :session, only: %i[new create destroy]
  # Signed-in device management ("sign out everywhere"). First properly
  # protected routes — the auth/verification gates are negative-tested here.
  resources :sessions, only: %i[index destroy], controller: :user_sessions, as: :user_sessions

  # Passwordless login: request a code, or tap the emailed magic link.
  resource :login_code, only: :create
  get "login_code/:token" => "login_codes#confirm", as: :confirm_login_code

  resources :passwords, param: :token, only: %i[new create edit update]

  # Lockout recovery (auth plan_3): the emailed unlock link.
  get "unlock/:token" => "unlocks#show", as: :unlock

  resource :theme_preference, only: :update

  # Component gallery: dev/staging only. A lambda, not an `unless` around
  # draw — per-request evaluation keeps the production 404 testable.
  get "gallery" => "gallery#show", constraints: ->(_request) { !Rails.env.production? }

  # The org switcher/front door, and everything org-scoped under
  # /o/:org_slug (organizations-users plan_2). The slug constraint 404s
  # malformed slugs before they reach a query.
  resources :organizations, only: %i[index new create]
  scope "o/:org_slug", module: :org, as: :org, constraints: { org_slug: /[a-z0-9-]+/ } do
    root "home#show", as: :root
  end

  # Temporary root until marketing-site-seo delivers a landing page.
  root "health#full"
end
