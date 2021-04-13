# frozen_string_literal: true

require "decidim/direct_verifications/instrumenter"

module Decidim
  module DirectVerifications
    class RegisterUsersJob < ApplicationJob
      queue_as :default

      def perform(userslist, organization, user)
        @emails = Verification::MetadataParser.new(userslist).to_h
        @organization = organization
        @current_user = user
        @instrumenter = Instrumenter.new(current_user)

        register_users
        send_email_notification
      end

      private

      attr_reader :organization, :current_user, :instrumenter, :emails

      def register_users
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
        ImportMailer.finished_registration(current_user, instrumenter).deliver_now
      end
    end
  end
end
