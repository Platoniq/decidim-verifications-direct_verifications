# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      module Admin
        class ImportsController < Decidim::Admin::ApplicationController
          def new; end

          def create
            userslist = params[:file].read
            RegisterUsersJob.perform_later(userslist, current_organization, current_user)

            flash[:notice] = t(".success")
            redirect_to decidim_admin_direct_verifications.new_import_path
          end
        end
      end
    end
  end
end
