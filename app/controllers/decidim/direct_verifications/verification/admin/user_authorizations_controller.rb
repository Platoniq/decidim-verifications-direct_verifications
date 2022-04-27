# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      module Admin
        class UserAuthorizationsController < Decidim::Admin::ApplicationController
          include NeedsPermission
          layout false

          helper_method :user, :authorizations, :authorization_for, :managed?

          def show; end

          def update
            handler = OpenStruct.new(handler_name: params[:name], user: user, unique_id: nil, metadata: {})
            if Decidim::Authorization.create_or_update_from(handler)
              flash[:notice] = t(".success", name: auth_name)
            else
              flash[:alert] = t(".error", name: auth_name)
            end
            redirect_to decidim_admin.officializations_path
          end

          def destroy
            begin
              authorization_for(params[:name]).destroy!
              flash[:notice] = t(".success", name: auth_name)
            rescue StandardError => e
              flash[:alert] = t(".error", name: auth_name, error: e.message)
            end
            redirect_to decidim_admin.officializations_path
          end

          private

          def user
            @user ||= Decidim::User.find_by(id: params[:id])
          end

          def authorizations
            @authorizations ||= Decidim::Authorization.where(decidim_user_id: user.id)
          end

          def authorization_for(name)
            authorizations.find_by(name: name)
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
