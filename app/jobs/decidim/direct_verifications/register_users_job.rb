# frozen_string_literal: true

require "decidim/direct_verifications/instrumenter"

module Decidim
  module DirectVerifications
    class RegisterUsersJob < BaseImportJob
      def process_users
        emails.each do |email, data|
          name = if data.is_a?(Hash)
                   data[:name]
                 else
                   data
                 end
          RegisterUser.new(email, name, organization, current_user, instrumenter).call
        end
      end

      def type
        :registered
      end
    end
  end
end
