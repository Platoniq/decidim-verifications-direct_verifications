# frozen_string_literal: true

module Decidim
  module Verifications
    module BatchUsers
      module Admin
        class BatchVerificationsController < Decidim::Admin::ApplicationController
          include NeedsPermission

          layout "decidim/admin/users"

          def index
            # enforce_permission_to :index
          end
        end
      end
    end
  end
end
