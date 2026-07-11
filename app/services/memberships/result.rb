# frozen_string_literal: true

module Memberships
  Result = Data.define(:membership, :error) do
    def success? = error.nil?
  end
end
