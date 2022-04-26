# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      module Admin
        class UserAuthorizationsController < Decidim::Admin::ApplicationController
          include NeedsPermission
          layout false

          helper_method :user, :authorizations, :authorization_granted?, :managed?

          def show; end

          private

          def user
            @user ||= Decidim::User.find_by(id: params[:id])
          end

          def authorizations
            @authorizations ||= Decidim::Authorization.where(decidim_user_id: user.id)
          end

          def authorization_granted?(name)
            authorizations.find_by(name: name)&.granted?
          end

          def managed?(name)
            Decidim::DirectVerifications.manage_workflows.include? name
          end
        end
      end
    end
  end
end
