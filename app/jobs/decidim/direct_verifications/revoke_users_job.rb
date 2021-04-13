# frozen_string_literal: true

module Decidim
  module DirectVerifications
    class RevokeUsersJob < BaseImportJob
      def process_users
        emails.each do |email, _name|
          RevokeUser.new(email, organization, instrumenter).call
        end
      end

      def send_email_notification
        ImportMailer.finished_processing(current_user, instrumenter, :revoked).deliver_now
      end
    end
  end
end
