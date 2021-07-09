# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::DirectVerifications::Verification

        paths["db/migrate"] = nil
        paths["lib/tasks"] = nil

        routes do
          resource :authorization, only: [:new], as: :authorization
          root to: "authorizations#new"
        end
      end
    end
  end
end
