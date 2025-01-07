# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      module Admin
        class DirectVerificationsController < ApplicationController
          include NeedsPermission
          helper_method :workflows, :current_authorization_handler

          layout "decidim/admin/users"

          def index
            enforce_permission_to :index, :authorization
          end

          def create
            enforce_permission_to :create, :authorization

            @userslist = params[:userslist]

            @processor = UserProcessor.new(current_organization, current_user, session, instrumenter)
            @processor.emails = parser_class.new(@userslist).to_h
            @processor.authorization_handler = current_authorization_handler

            @stats = UserStats.new(current_organization)
            @stats.authorization_handler = @processor.authorization_handler

            register_users
            authorize_users
            revoke_users

            render(action: :index) && return if show_users_info

            redirect_to direct_verifications_path
          rescue InputParserError => e
            flash[:error] = e.message
            redirect_to direct_verifications_path
          end

          private

          def instrumenter
            @instrumenter ||= Instrumenter.new(current_user)
          end

          def register_users
            return unless params[:register]

            @processor.register_users
            flash.now[:warning] = t(".registered", count: @processor.emails.count,
                                                   registered: instrumenter.processed_count(:registered),
                                                   errors: instrumenter.errors_count(:registered))
          end

          def authorize_users
            return unless params[:authorize] == "in"

            @processor.authorize_users
            flash.now[:notice] = t(".authorized", handler: t("#{@processor.authorization_handler}.name", scope: "decidim.authorization_handlers"),
                                                  count: @processor.emails.count,
                                                  authorized: instrumenter.processed_count(:authorized),
                                                  errors: instrumenter.errors_count(:authorized))
          end

          def revoke_users
            return unless params[:authorize] == "out"

            @processor.revoke_users
            flash.now[:notice] = t(".revoked", handler: t("#{@processor.authorization_handler}.name", scope: "decidim.authorization_handlers"),
                                               count: @processor.emails.count,
                                               revoked: instrumenter.processed_count(:revoked),
                                               errors: instrumenter.errors_count(:revoked))
          end

          def show_users_info
            return if params[:authorize].in? %w(in out)

            @stats.emails = @processor.emails.keys
            flash.now[:info] = t(".info", handler: t("#{@processor.authorization_handler}.name", scope: "decidim.authorization_handlers"),
                                          count: @processor.emails.count,
                                          authorized: @stats.authorized,
                                          unconfirmed: @stats.unconfirmed,
                                          registered: @stats.registered)
            true
          end

          def parser_class
            Decidim::DirectVerifications.find_parser_class(Decidim::DirectVerifications.input_parser)
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
