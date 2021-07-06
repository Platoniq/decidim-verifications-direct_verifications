# frozen_string_literal: true

require "decidim/direct_verifications/instrumenter"

module Decidim
  module DirectVerifications
    # This class implements the logic to import the user entries and sending an email notification
    # with the result. The specifics to process the entries are meant to be implemented by
    # subclasses which must implement the `#process_users` and `#type` methods.
    class BaseImportJob < ApplicationJob
      queue_as :default

      def perform(userslist, organization, current_user, authorization_handler)
        @emails = Verification::MetadataParser.new(userslist).to_h
        @organization = organization
        @current_user = current_user
        @instrumenter = Instrumenter.new(current_user)
        @authorization_handler = authorization_handler

        process_users
        send_email_notification
      end

      private

      attr_reader :emails, :organization, :current_user, :instrumenter, :authorization_handler

      def send_email_notification
        ImportMailer.finished_processing(
          current_user,
          instrumenter,
          type,
          authorization_handler
        ).deliver_now
      end
    end
  end
end
