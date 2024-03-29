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
          resources :authorizations, only: [:index, :destroy]
          resources :imports, only: [:new, :create]
          resources :user_authorizations, only: [:show, :update, :destroy]

          root to: "direct_verifications#index"
        end

        config.after_initialize do
          if Decidim::DirectVerifications.participants_modal.present?
            Decidim::Admin::OfficializationsController.include(Decidim::DirectVerifications::Admin::NeedsVerificationSnippets)
          end
        end

        initializer "direct_verifications.webpacker.assets_path" do
          Decidim.register_assets_path File.expand_path("app/packs", root)
        end
      end
    end
  end
end
