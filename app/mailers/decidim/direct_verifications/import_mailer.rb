# frozen_string_literal: true

module Decidim
  module DirectVerifications
    class ImportMailer < Decidim::Admin::ApplicationMailer
      include LocalisedMailer

      layout "decidim/mailer"

      def successful_import(user)
        @organization = user.organization

        with_user(user) do
          mail(
            to: user.email,
            subject: I18n.t("decidim.direct_verifications.verification.admin.imports.successful_import.subject")
          )
        end
      end
    end
  end
end
