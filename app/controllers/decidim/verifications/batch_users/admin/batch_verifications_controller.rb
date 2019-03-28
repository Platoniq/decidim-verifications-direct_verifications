# frozen_string_literal: true

module Decidim
  module Verifications
    module BatchUsers
      module Admin
        class BatchVerificationsController < Decidim::Admin::ApplicationController
          include NeedsPermission

          layout "decidim/admin/users"

          def index
            enforce_permission_to :index, UserProcessor
          end

          def create
            enforce_permission_to :index, UserProcessor
            processor = UserProcessor.new params[:userlist]
            if params[:register]
              # register users, send invitation
              processor.register_users
            end
            if params[:authorize]
              # find users, authorize them
              processor.authorize_users
            end
            puts '************'
            puts params
            puts processor.user_hash
            puts '************'
            flash[:notice] = t(".success", count: 1,
                                             errors: 'errors')
            flash[:notice] = processor.user_hash
            redirect_to batch_verifications_path
          end

          def permission_class_chain
            [
              Decidim::Verifications::BatchUsers::Admin::Permissions,
              Decidim::Admin::Permissions,
              Decidim::Permissions
            ]
          end

          def permission_scope
            :admin
          end

        end
      end
    end
  end
end
