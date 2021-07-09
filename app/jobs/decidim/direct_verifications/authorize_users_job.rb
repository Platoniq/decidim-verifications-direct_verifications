# frozen_string_literal: true

require "decidim/direct_verifications/instrumenter"

module Decidim
  module DirectVerifications
    class AuthorizeUsersJob < BaseImportJob
      class NullSession; end

      def process_users
        emails.each do |email, data|
          AuthorizeUser.new(
            email,
            data,
            session,
            organization,
            instrumenter,
            authorization_handler
          ).call
        end
      end

      def type
        :authorized
      end

      private

      def session
        NullSession.new
      end
    end
  end
end
