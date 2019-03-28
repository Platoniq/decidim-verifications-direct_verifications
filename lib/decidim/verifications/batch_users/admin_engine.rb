# frozen_string_literal: true

module Decidim
  module Verifications
    module BatchUsers
      class AdminEngine < ::Rails::Engine
        isolate_namespace Decidim::Verifications::BatchUsers::Admin
        paths["db/migrate"] = nil

        routes do
          resources :batch_verifications, only: %i[index create]

          root to: "batch_verifications#index"
        end
      end
    end
  end
end