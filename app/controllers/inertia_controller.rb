# frozen_string_literal: true

class InertiaController < ApplicationController
  # Shared with every Inertia page (https://inertia-rails.dev/guide/shared-data).
  # theme: the account-level preference; null pre-login (the no-flash
  # script in the layout falls back to localStorage, then the OS).
  inertia_share theme: -> { Current.user&.theme_preference }
end
