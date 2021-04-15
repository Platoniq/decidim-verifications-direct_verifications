# frozen_string_literal: true

module Decidim
  module DirectVerifications
    class RevokeUsersJob < BaseImportJob
      def process_users
        emails.each do |email, _name|
          RevokeUser.new(email, organization, instrumenter).call
        end
      end

      def type
        :revoked
      end
    end
  end
end
