# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      module Admin
        class DirectVerificationsController < Decidim::Admin::ApplicationController
          include NeedsPermission

          layout "decidim/admin/users"

          def index
            enforce_permission_to :index, UserProcessor
          end

          def create
            enforce_permission_to :create, UserProcessor

            @userlist = params[:userlist]
            processor = UserProcessor.new(current_organization, current_user)
            processor.emails = extract_emails_to_hash @userlist
            processor.authorization_handler = params[:authorization_handler] if params[:authorization_handler]
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
              flash[:info] = t(".info", handler: t("#{processor.authorization_handler}.name", scope: "decidim.authorization_handlers"),
                                        count: processor.emails.count,
                                        authorized: processor.total(:authorized),
                                        unconfirmed: processor.total(:unconfirmed),
                                        registered: processor.total(:registered))
              render(action: :index) && return
            end
            redirect_to direct_verifications_path
          end

          def permission_class_chain
            [
              Decidim::DirectVerifications::Verification::Admin::Permissions,
              Decidim::Admin::Permissions,
              Decidim::Permissions
            ]
          end

          def permission_scope
            :admin
          end

          private

          def extract_emails_to_hash(txt)
            reg = /([^@\r\n]*)\b([A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,})\b/i
            txt.scan(reg).map do |m|
              [
                m[1].delete("<>").strip,
                m[0].gsub(/[^[:print:]]|[\"\$\<\>\|\\]/, "").strip
              ]
            end .to_h
          end
        end
      end
    end
  end
end
