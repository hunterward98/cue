# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "Cue <no-reply@example.com>" # real domain lands with notifications plan_2
  layout "mailer"
end
