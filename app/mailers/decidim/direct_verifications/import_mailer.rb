# frozen_string_literal: true

module Decidim
  module DirectVerifications
    class ImportMailer < Decidim::Admin::ApplicationMailer
      Stats = Struct.new(:count, :registered, :errors, keyword_init: true)

      include LocalisedMailer

      layout "decidim/mailer"

      def finished_registration(user, instrumenter)
        @organization = user.organization
        @stats = Stats.new(
          count: instrumenter.emails_count(:registered),
          registered: instrumenter.processed_count(:registered),
          errors: instrumenter.errors_count(:registered)
        )

        with_user(user) do
          mail(
            to: user.email,
            subject: I18n.t("decidim.direct_verifications.verification.admin.imports.mailer.subject")
          )
        end
      end
    end
  end
end
