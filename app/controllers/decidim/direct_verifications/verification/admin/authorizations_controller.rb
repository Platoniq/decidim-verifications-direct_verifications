# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      module Admin
        class AuthorizationsController < Decidim::Admin::ApplicationController
          layout "decidim/admin/users"

          def index
            enforce_permission_to :index, :authorization
            @authorizations = collection
          end

          def destroy
            if authorization.destroy
              flash[:notice] = "successfully"
              redirect_to authorizations_path
            end
          end

          private

          def collection
            Decidim::Authorization.where(name: "direct_verifications").includes(:user)
          end

          def authorization
            @authorization ||= collection.find_by(id: params[:id])
          end
        end
      end
    end
  end
end
