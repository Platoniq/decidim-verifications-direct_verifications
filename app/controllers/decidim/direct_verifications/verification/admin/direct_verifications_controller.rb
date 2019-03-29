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
            processor.emails = extract_emails_to_hash params[:userlist]
            processor.register_users if params[:register]
            processor.authorize_users if params[:authorize]

            flash[:notice] = t(".success", count: processor.success.count,
                                             errors: processor.errors.count)
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
            txt.scan(reg).map {|m| [m[1], m[0].delete('<>').strip]}.to_h
          end

        end
      end
    end
  end
end
