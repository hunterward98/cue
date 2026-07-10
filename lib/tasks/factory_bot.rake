# frozen_string_literal: true

namespace :factory_bot do
  desc "Build every factory (with traits) and fail on invalid records"
  task lint: :environment do
    unless Rails.env.test?
      exec({ "RAILS_ENV" => "test" }, "bin/rails", "factory_bot:lint")
    end

    ActiveRecord::Base.transaction do
      FactoryBot.lint traits: true
      raise ActiveRecord::Rollback
    end
  end
end
