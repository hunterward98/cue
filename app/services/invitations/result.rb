# frozen_string_literal: true

module Invitations
  Result = Data.define(:invitation, :error) do
    def success? = error.nil?
  end
end
