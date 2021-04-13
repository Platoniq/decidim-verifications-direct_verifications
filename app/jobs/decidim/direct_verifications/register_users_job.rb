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

      def send_email_notification
        ImportMailer.finished_processing(current_user, instrumenter, :registered).deliver_now
      end
    end
  end
end
