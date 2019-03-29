# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      class AdminEngine < ::Rails::Engine
        isolate_namespace Decidim::DirectVerifications::Verification::Admin
        paths["db/migrate"] = nil

        routes do
          resources :direct_verifications, only: [:index, :create]

          root to: "direct_verifications#index"
        end
      end
    end
  end
end
