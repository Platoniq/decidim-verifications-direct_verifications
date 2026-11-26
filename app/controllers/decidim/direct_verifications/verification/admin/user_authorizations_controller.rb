# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      module Admin
        class UserAuthorizationsController < ApplicationController
          include NeedsPermission
          layout false

          helper_method :user, :authorizations, :authorization_for, :managed?

          def show
            enforce_permission_to :index, :authorization
          end

          def update
            enforce_permission_to :create, :direct_authorization, name: params[:name]
            handler = OpenStruct.new(handler_name: params[:name], user:, authorization_attributes: OpenStruct.new(unique_id: nil, metadata: {}))
            if Decidim::Authorization.create_or_update_from(handler)
              flash[:notice] = t(".success", name: auth_name)
            else
              flash[:alert] = t(".error", name: auth_name)
            end
            redirect_to decidim_admin.officializations_path
          end

          def destroy
            enforce_permission_to :destroy, :direct_authorization, name: params[:name]
            user # not found for users of other organizations, before the rescue below
            begin
              authorization_for(params[:name]).destroy!
              flash[:notice] = t(".success", name: auth_name)
            rescue StandardError => e
              flash[:alert] = t(".error", name: auth_name, message: e.message)
            end
            redirect_to decidim_admin.officializations_path
          end

          private

          def user
            # Only users of the current organization (raises not found otherwise).
            @user ||= current_organization.users.find(params[:id])
          end

          def authorizations
            # `user` is already scoped to the current organization.
            @authorizations ||= Decidim::Authorization.where(decidim_user_id: user.id) # rubocop:disable Decidim/OrganizationScopedFinder
          end

          def authorization_for(name)
            authorizations.find_by(name:)
          end

          def managed?(name)
            Decidim::DirectVerifications.manage_workflows.include? name
          end

          def auth_name
            t("decidim.authorization_handlers.#{params[:name]}.name", default: params[:name])
          end
        end
      end
    end
  end
end
