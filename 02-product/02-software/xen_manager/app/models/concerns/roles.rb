module Roles
  extend ActiveSupport::Concern

  ROLES = %w[guest user admin].freeze

  ENTITLEMENTS = %w[CREATOR ACTIVATOR MONITOR EDITOR].freeze

  ROLE_ENTITLEMENTS = {
    "guest" => %w[MONITOR],
    "user"  => %w[MONITOR ACTIVATOR],
    "admin" => %w[CREATOR EDITOR MONITOR ACTIVATOR]
  }.freeze

  def can?(entitlement)
    ROLE_ENTITLEMENTS.fetch(role, []).include?(entitlement.to_s.upcase)
  end
end
