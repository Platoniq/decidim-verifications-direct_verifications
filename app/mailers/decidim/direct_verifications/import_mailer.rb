# frozen_string_literal: true

module Decidim
  module DirectVerifications
    class ImportMailer < Decidim::Admin::ApplicationMailer
      include LocalisedMailer

      def successful_import(user)
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
