# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      module Admin
        class AuthorizationsController < ApplicationController
          layout "decidim/admin/users"

          def index
            enforce_permission_to :index, :authorization
            @authorizations = collection.includes(:user)
                                        .page(params[:page])
                                        .per(15)
          end

          def destroy
            if authorization.destroy
              flash[:notice] = "successfully"
              redirect_to authorizations_path
            end
          end

          private

          def collection
            # Decidim::Verifications::Authorizations Query
            Decidim::Verifications::Authorizations.new(
              organization: current_organization,
              name: "direct_verifications",
              granted: true
            ).query
          end

          def authorization
            @authorization ||= collection.find_by(id: params[:id])
          end
        end
      end
    end
  end
end
