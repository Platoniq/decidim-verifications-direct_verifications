# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      class AuthorizationsController < Decidim::ApplicationController
        # Only tells the user this verification is granted by admins; nothing to authorize.
        def new # rubocop:disable Decidim/EnforcePermissionTo
          flash[:alert] = t("authorizations.new.no_action", scope: "decidim.direct_verifications.verification")
          redirect_to decidim_verifications.authorizations_path
        end
      end
    end
  end
end
