# frozen_string_literal: true

module Decidim
  module DirectVerifications
    class ImportMailer < Decidim::Admin::ApplicationMailer
      include LocalisedMailer

      layout "decidim/mailer"

      I18N_SCOPE = "decidim.direct_verifications.verification.admin.imports.mailer"

      def finished_processing(user, instrumenter, type, handler)
        @stats = Stats.from(instrumenter, type)
        @organization = user.organization
        @i18n_key = "#{I18N_SCOPE}.#{type}"
        @handler = handler

        with_user(user) do
          mail(
            to: user.email,
            subject: I18n.t("#{I18N_SCOPE}.subject")
          )
        end
      end
    end
  end
end
