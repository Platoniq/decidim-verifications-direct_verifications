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

            processor = UserProcessor.new(current_organization, current_user)
            @userlist = params[:userlist]
            processor.emails = extract_emails_to_hash @userlist
            processor.authorization_handler = params[:authorization_handler] if params[:authorization_handler]
            if params[:register]
              processor.register_users
              flash[:warning] = t(".registered", count: processor.emails.count,
                                                 registered: processor.processed[:registered].count,
                                                 errors: processor.errors[:registered].count)
            end
            if params[:authorize]
              processor.authorize_users
              flash[:notice] = t(".authorized", handler: t("#{processor.authorization_handler}.name", scope: "decidim.authorization_handlers"),
                                                count: processor.emails.count,
                                                authorized: processor.processed[:authorized].count,
                                                errors: processor.errors[:authorized].count)
            end
            unless params[:authorize] || params[:register]
              flash[:info] = t(".info", handler: t("#{processor.authorization_handler}.name", scope: "decidim.authorization_handlers"),
                                        count: processor.emails.count,
                                        authorized: processor.total(:authorized),
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

          # TODO: dirty text test:
          # test1@test.com
          # test2@test.com
          # use test3@t.com
          # User <a@b.co> another@email.com third@email.com@as.com
          # Test 1 test1@test.com
          def extract_emails_to_hash(txt)
            reg = /([^@\r\n]*)\b([A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,})\b/i
            txt.scan(reg).map { |m| [m[1], m[0].delete("<>").strip] }.to_h
          end
        end
      end
    end
  end
end
