# frozen_string_literal: true

module Decidim
  module DirectVerifications
    class ImportMailerPreview < ActionMailer::Preview
      def finished_registration
        user = User.first

        instrumenter = Instrumenter.new(user)
        instrumenter.add_processed(:registered, "email@example.com")

        ImportMailer.finished_registration(user, instrumenter)
      end
    end
  end
end
