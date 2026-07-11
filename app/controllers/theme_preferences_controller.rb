# frozen_string_literal: true

# Persists the theme choice on the account (theming plan_2). The client
# applies the theme optimistically; this just makes it follow the user
# to their next device.
class ThemePreferencesController < ApplicationController
  def update
    theme = params[:theme].to_s
    unless User::THEME_PREFERENCES.include?(theme)
      return head :unprocessable_entity
    end

    Current.user.update!(theme_preference: theme)
    redirect_back fallback_location: organizations_path
  end
end
