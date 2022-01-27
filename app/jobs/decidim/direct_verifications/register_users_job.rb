# frozen_string_literal: true

require "decidim/direct_verifications/instrumenter"

module Decidim
  module DirectVerifications
    class RegisterUsersJob < BaseImportJob
      def process_users
        Rails.logger.info "RegisterUsersJob: Registering #{emails.count} emails"
        emails.each do |email, data|
          RegisterUser.new(email, data, organization, current_user, instrumenter).call
        end
      end

      def type
        :registered
      end
    end
  end
end
