Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  # Cheap liveness probe (200 if the app boots) for load balancers.
  get "up" => "rails/health#show", as: :rails_health_check

  # Deep health check proving Rails → Inertia → React → Tailwind → DB
  # (foundation plan_2). Returns 503 if any layer fails.
  get "up/full" => "health#full", as: :full_health_check

  # Temporary root until marketing-site-seo delivers a landing page.
  root "health#full"
end
