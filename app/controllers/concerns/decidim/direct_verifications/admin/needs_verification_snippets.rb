# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module DirectVerifications
    module Admin
      module NeedsVerificationSnippets
        extend ActiveSupport::Concern

        included do
          helper_method :snippets
        end

        def snippets
          return @snippets if @snippets

          @snippets = Decidim::Snippets.new

          @snippets.add(:direct_verifications, "<script>DirectVerificationsConfig = #{direct_verifications_config.to_json}</script>")
          @snippets.add(:direct_verifications, ActionController::Base.helpers.javascript_pack_tag("decidim_direct_verifications_participants"))
          @snippets.add(:head, @snippets.for(:direct_verifications))

          @snippets
        end

        def direct_verifications_config
          {
            buttonTitle: "See verifications", # TODO: i18n
            verifications: direct_verifications_verifications
          }
        end

        def direct_verifications_verifications
          @direct_verifications_verifications ||= Decidim::Authorization.where(decidim_user_id: filtered_collection).map do |auth|
            {
              id: auth.decidim_user_id,
              name: auth.name,
              createdAt: auth.created_at,
              updatedAt: auth.updated_at
            }
          end
        end
      end
    end
  end
end
