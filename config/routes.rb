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

  # Temporary root until marketing-site-seo delivers a landing page.
  root "health#full"
end
