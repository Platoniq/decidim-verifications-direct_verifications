# frozen_string_literal: true

module Decidim
  module DirectVerifications
    class RevokeUsersJob < BaseImportJob
      def process_users
        Rails.logger.info "RevokeUsersJob: Revoking #{emails.count} emails"
        emails.each do |email, _name|
          RevokeUser.new(email, organization, instrumenter, authorization_handler).call
        end
      end

      def type
        :revoked
      end
    end
  end
end
