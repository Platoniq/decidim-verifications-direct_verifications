# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      module Admin
        class AuthorizationsController < Decidim::Admin::ApplicationController
          layout "decidim/admin/users"

          def index
            @authorizations = Decidim::Authorization.where(name: "direct_verifications")
          end
        end
      end
    end
  end
end
