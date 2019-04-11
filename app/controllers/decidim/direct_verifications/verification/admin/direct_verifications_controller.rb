# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      module Admin
        class DirectVerificationsController < Decidim::Admin::ApplicationController
          include NeedsPermission

          layout "decidim/admin/users"

          def index
            enforce_permission_to :index, :authorization
            @authorization_handler = :direct_verifications
            @workflows = workflows
          end

          def create
            enforce_permission_to :create, :authorization

            @userlist = params[:userlist]
            @workflows = workflows
            processor = UserProcessor.new(current_organization, current_user)
            processor.emails = extract_emails_to_hash @userlist
            processor.authorization_handler = authorization_handler(params[:authorization_handler])
            stats = UserStats.new(current_organization)
            stats.authorization_handler = processor.authorization_handler
            if params[:register]
              processor.register_users
              flash[:warning] = t(".registered", count: processor.emails.count,
                                                 registered: processor.processed[:registered].count,
                                                 errors: processor.errors[:registered].count)
            end
            if params[:authorize] == "in"
              processor.authorize_users
              flash[:notice] = t(".authorized", handler: t("#{processor.authorization_handler}.name", scope: "decidim.authorization_handlers"),
                                                count: processor.emails.count,
                                                authorized: processor.processed[:authorized].count,
                                                errors: processor.errors[:authorized].count)
            elsif params[:authorize] == "out"
              processor.revoke_users
              flash[:notice] = t(".revoked", handler: t("#{processor.authorization_handler}.name", scope: "decidim.authorization_handlers"),
                                             count: processor.emails.count,
                                             revoked: processor.processed[:revoked].count,
                                             errors: processor.errors[:revoked].count)
            else
              stats.emails = processor.emails.keys
              flash[:info] = t(".info", handler: t("#{processor.authorization_handler}.name", scope: "decidim.authorization_handlers"),
                                        count: processor.emails.count,
                                        authorized: stats.authorized,
                                        unconfirmed: stats.unconfirmed,
                                        registered: stats.registered)
              render(action: :index) && return
            end
            redirect_to direct_verifications_path
          end

          private

          def extract_emails_to_hash(txt)
            reg = /([A-Z0-9+._-]+@[A-Z0-9._-]+\.[A-Z0-9_-]+)\b/i
            emails = {}
            txt.split(/[\r\n;,]/).each do |line|
              reg.match line do |m|
                n = line.split(m[0]).first
                emails[m[0]] = (n.presence || "").gsub(/[^[:print:]]|[\"\$\<\>\|\\]/, "").strip
              end
            end
            emails
          end

          def authorization_handler(authorization_handler)
            @authorization_handler = authorization_handler.presence || :direct_verifications
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
