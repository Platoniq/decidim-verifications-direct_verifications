# frozen_string_literal: true

require "decidim/direct_verifications/instrumenter"

module Decidim
  module DirectVerifications
    # This class implements the logic to import the user entries and sending an email notification
    # with the result. The specifics to process the entries are meant to be implemented by
    # subclasses which must implement the `#process_users` and `#type` methods.
    class BaseImportJob < ApplicationJob
      queue_as :default

      def perform(path, organization, current_user)
        userslist = File.read(path)
        @emails = Verification::MetadataParser.new(userslist).to_h
        @organization = organization
        @current_user = current_user
        @instrumenter = Instrumenter.new(current_user)

        process_users
        send_email_notification
      end

      private

      attr_reader :emails, :organization, :current_user, :instrumenter

      def send_email_notification
        ImportMailer.finished_processing(current_user, instrumenter, type).deliver_now
      end
    end
  end
end
