# frozen_string_literal: true

require "decidim/direct_verifications/instrumenter"

module Decidim
  module DirectVerifications
    # This class implements the logic to import the user entries and sending an email notification
    # with the result. The specifics to process the entries are meant to be implemented by
    # subclasses which must implement the `#process_users` and `#type` methods.
    class BaseImportJob < ApplicationJob
      queue_as :default

      def perform(filename, organization, current_user, authorization_handler)
        @filename = filename
        @organization = organization
        @current_user = current_user
        @authorization_handler = authorization_handler

        begin
          @emails = Parsers::MetadataParser.new(userslist).to_h
          @instrumenter = Instrumenter.new(current_user)

          Rails.logger.info "BaseImportJob: Processing file #{filename}"
          process_users
          send_email_notification
        rescue StandardError => e
          Rails.logger.error "BaseImportJob Error: #{e.message} #{e.backtrace.filter { |f| f =~ /direct_verifications/ }}"
        end
        remove_file!
      end

      private

      attr_reader :uploader, :filename, :emails, :organization, :current_user, :instrumenter, :authorization_handler

      def userslist
        return @userslist if @userslist

        @uploader = CsvUploader.new(organization)
        @uploader.retrieve_from_store!(filename)
        @userslist = @uploader.file.read.force_encoding("UTF-8")
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
        uploader.remove!
      end
    end
  end
end
