# frozen_string_literal: true

module Organizations
  # Org creation: the creator becomes the first (active) owner in the same
  # transaction, so an ownerless org can never exist through the app.
  class CreateWithOwner
    Result = Data.define(:organization, :errors) do
      def success? = errors.nil?
    end

    def self.call(**kwargs) = new(**kwargs).call

    def initialize(user:, name:, slug:)
      @user = user
      @name = name
      @slug = slug
    end

    def call
      organization = Organization.new(name: @name, slug: @slug,
                                      settings: Organization::DEFAULT_SETTINGS)
      ActiveRecord::Base.transaction do
        return Result.new(organization: nil, errors: organization.errors) unless organization.save

        ActsAsTenant.with_tenant(organization) do
          organization.memberships.create!(user: @user, state: "active", owner: true)
        end
      end
      Result.new(organization:, errors: nil)
    end
  end
end
