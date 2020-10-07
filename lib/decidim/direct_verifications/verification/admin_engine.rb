# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      class AdminEngine < ::Rails::Engine
        isolate_namespace Decidim::DirectVerifications::Verification::Admin
        paths["db/migrate"] = nil

        routes do
          resources :direct_verifications, only: [:index, :create, :stats]
          resources :stats, only: [:index]
          resources :authorizations, only: [:index]

          root to: "direct_verifications#index"
        end

        initializer "decidim_direct_verifications.admin_assets" do |app|
          app.config.assets.precompile += %w(direct_verifications_admin_manifest.js)
        end
      end
    end
  end
end
