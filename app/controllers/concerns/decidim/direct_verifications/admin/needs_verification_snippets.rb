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
            buttonTitle: I18n.t("decidim.direct_verifications.participants.modal.button_title", locale: detect_current_locale),
            modalTitle: I18n.t("decidim.direct_verifications.participants.modal.modal_title", locale: detect_current_locale),
            closeModalLabel: I18n.t("decidim.direct_verifications.participants.modal.close_modal_label", locale: detect_current_locale),
            statsLabel: I18n.t("decidim.direct_verifications.verification.admin.index.stats", locale: detect_current_locale),
            userVerificationsPath: Decidim::DirectVerifications::Verification::AdminEngine.routes.url_helpers.user_authorization_path("-ID-"),
            statsPath: Decidim::DirectVerifications::Verification::AdminEngine.routes.url_helpers.stats_path,
            verifications: direct_verifications_verifications
          }
        end

        def direct_verifications_verifications
          @direct_verifications_verifications ||= Decidim::Authorization.where(name: current_organization.available_authorizations)
                                                                        .where.not(granted_at: nil)
                                                                        .where(decidim_user_id: filtered_collection).map do |auth|
            {
              id: auth.id,
              userId: auth.decidim_user_id,
              name: auth.name,
              title: I18n.t("decidim.authorization_handlers.#{auth.name}.name", locale: detect_current_locale, default: auth.name),
              createdAt: auth.created_at,
              updatedAt: auth.updated_at
            }
          end
        end

        def detect_current_locale
          params[:locale] || session[:user_locale] || locale
        end
      end
    end
  end
end
