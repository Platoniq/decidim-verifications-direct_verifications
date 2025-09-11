# frozen_string_literal: true

require "decidim/direct_verifications/instrumenter"

module Decidim
  module DirectVerifications
    # This class implements the logic to import the user entries and sending an email notification
    # with the result. The specifics to process the entries are meant to be implemented by
    # subclasses which must implement the `#process_users` and `#type` methods.
    class BaseImportJob < ApplicationJob
      queue_as :default

      def perform(blob_id, organization, current_user, authorization_handler, options = {})
        @blob = ActiveStorage::Blob.find(blob_id)
        @organization = organization
        @current_user = current_user
        @authorization_handler = authorization_handler

        begin
          @emails = Parsers::MetadataParser.new(userslist).to_h
          @instrumenter = Instrumenter.new(current_user)

          Rails.logger.info "BaseImportJob: Processing file #{@blob.filename}"
          process_users
          send_email_notification
        rescue StandardError => e
          Rails.logger.error "BaseImportJob Error: #{e.message} #{e.backtrace.grep(/direct_verifications/)}"
        end
        remove_file! if options.fetch(:remove_file, false)
      end

      private

      attr_reader :blob, :emails, :organization, :current_user, :instrumenter, :authorization_handler

      def userslist
        @userslist ||= blob.download.force_encoding("UTF-8")
      end

      def send_email_notification
        ImportMailer.finished_processing(
          current_user,
          instrumenter,
          type,
          authorization_handler
        ).deliver_now
      end

      def remove_file!
        blob.purge
      end
    end
  end
end
