# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      module Admin
        class ImportsController < Decidim::Admin::ApplicationController
          def new; end

          def create
            CreateImport.call(params[:file], current_organization, current_user) do
              on(:ok) do
                flash[:notice] = t(".success")
                redirect_to decidim_admin_direct_verifications.new_import_path
              end
            end
          end
        end
      end
    end
  end
end
