# frozen_string_literal: true

# Tenancy layer 1 of ADR 0010: automatic query scoping. require_tenant
# makes the failure mode loud — a tenant-model query with no tenant set
# raises instead of silently returning every org's rows. Legitimate
# cross-org reads (the org switcher, support console) opt out explicitly
# with ActsAsTenant.without_tenant.
ActsAsTenant.configure do |config|
  config.require_tenant = true
end
