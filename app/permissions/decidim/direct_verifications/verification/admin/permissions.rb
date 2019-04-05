# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      module Admin
        # Defines the abilities related to direct_verifications for a logged in admin user.
        class Permissions < Decidim::DefaultPermissions
          def permissions
            return permission_action if permission_action.scope != :admin
            if user.organization.available_authorizations.include?("direct_verifications")
              allow! if permission_action.subject == Decidim::DirectVerifications::UserProcessor
              allow! if permission_action.subject == Decidim::DirectVerifications::UserStats
              permission_action
            end
          end
        end
      end
    end
  end
end
