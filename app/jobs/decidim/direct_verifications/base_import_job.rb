# frozen_string_literal: true

require "decidim/direct_verifications/instrumenter"

module Decidim
  module DirectVerifications
    class BaseImportJob < ApplicationJob
      queue_as :default

      def perform(userslist, organization, current_user)
        @emails = Verification::MetadataParser.new(userslist).to_h
        @organization = organization
        @current_user = current_user
        @instrumenter = Instrumenter.new(current_user)

        process_users
        send_email_notification
      end

      private

      attr_reader :emails, :organization, :current_user, :instrumenter
    end
  end
end
