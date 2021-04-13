# frozen_string_literal: true

module Decidim
  module DirectVerifications
    class RevokeUsersJob < ApplicationJob
      queue_as :default

      def perform(userslist, organization, current_user)
        @emails = Verification::MetadataParser.new(userslist).to_h
        @organization = organization
        @current_user = current_user
        @instrumenter = Instrumenter.new(current_user)

        revoke_users
        send_email_notification
      end

      private

      attr_reader :emails, :organization, :current_user, :instrumenter

      def revoke_users
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
