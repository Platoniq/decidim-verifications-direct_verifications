# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      module Admin
        class ApplicationController < Decidim::Admin::ApplicationController
          def permission_class_chain
            [::Decidim::DirectVerifications::Admin::Permissions] + super
          end
        end
      end
    end
  end
end
