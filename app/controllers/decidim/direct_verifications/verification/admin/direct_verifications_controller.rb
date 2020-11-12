# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      module Admin
        class DirectVerificationsController < Decidim::Admin::ApplicationController
          include NeedsPermission
          helper_method :workflows, :current_authorization_handler

          layout "decidim/admin/users"

          def index
            enforce_permission_to :index, :authorization
          end

          def create
            enforce_permission_to :create, :authorization

            @userslist = params[:userlist]
            @processor = UserProcessor.new(current_organization, current_user, session)
            @processor.emails = parser_class.new(@userslist).to_h
            @processor.authorization_handler = current_authorization_handler
            @stats = UserStats.new(current_organization)
            @stats.authorization_handler = @processor.authorization_handler
            register_users
            authorize_users
            revoke_users

            render(action: :index) && return if show_users_info

            redirect_to direct_verifications_path
          end

          private

          def register_users
            return unless params[:register]

            @processor.register_users
            flash[:warning] = t(".registered", count: @processor.emails.count,
                                               registered: @processor.processed[:registered].count,
                                               errors: @processor.errors[:registered].count)
          end

          def authorize_users
            return unless params[:authorize] == "in"

            @processor.authorize_users
            flash[:notice] = t(".authorized", handler: t("#{@processor.authorization_handler}.name", scope: "decidim.authorization_handlers"),
                                              count: @processor.emails.count,
                                              authorized: @processor.processed[:authorized].count,
                                              errors: @processor.errors[:authorized].count)
          end

          def revoke_users
            return unless params[:authorize] == "out"

            @processor.revoke_users
            flash[:notice] = t(".revoked", handler: t("#{@processor.authorization_handler}.name", scope: "decidim.authorization_handlers"),
                                           count: @processor.emails.count,
                                           revoked: @processor.processed[:revoked].count,
                                           errors: @processor.errors[:revoked].count)
          end

          def show_users_info
            return if params[:authorize]

            @stats.emails = @processor.emails.keys
            flash.now[:info] = t(".info", handler: t("#{@processor.authorization_handler}.name", scope: "decidim.authorization_handlers"),
                                          count: @processor.emails.count,
                                          authorized: @stats.authorized,
                                          unconfirmed: @stats.unconfirmed,
                                          registered: @stats.registered)
            true
          end

          def parser_class
            if Rails.configuration.direct_verifications_parser == :metadata
              MetadataParser
            else
              NameParser
            end
          end

          def authorization_handler(authorization_handler)
            @authorization_handler = authorization_handler.presence || :direct_verifications
          end

          def current_authorization_handler
            authorization_handler(params[:authorization_handler])
          end

          def configured_workflows
            return Decidim::DirectVerifications.config.manage_workflows if Decidim::DirectVerifications.config

            ["direct_verifications"]
          end

          def workflows
            workflows = configured_workflows & current_organization.available_authorizations.map.to_a
            workflows.map do |a|
              [t("#{a}.name", scope: "decidim.authorization_handlers"), a]
            end
          end
        end
      end
    end
  end
end
