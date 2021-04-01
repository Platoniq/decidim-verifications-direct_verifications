# frozen_string_literal: true

require "decidim/direct_verifications/register_user"
require "decidim/direct_verifications/authorize_user"
require "decidim/direct_verifications/revoke_user"

module Decidim
  module DirectVerifications
    class UserProcessor
      def initialize(organization, current_user, session)
        @organization = organization
        @current_user = current_user
        @authorization_handler = :direct_verifications
        @errors = { registered: [], authorized: [], revoked: [] }
        @processed = { registered: [], authorized: [], revoked: [] }
        @emails = {}
        @session = session
      end

      attr_reader :organization, :current_user, :session, :errors, :processed
      attr_accessor :authorization_handler, :emails

      def register_users
        emails.each do |email, data|
          name = if data.is_a?(Hash)
                   data[:name]
                 else
                   data
                 end
          RegisterUser.new(email, name, organization, current_user, self).call
        end
      end

      def authorize_users
        emails.each do |email, data|
          AuthorizeUser.new(email, data, session, organization, self).call
        end
      end

      def revoke_users
        emails.each do |email, _name|
          RevokeUser.new(email, organization, self).call
        end
      end

      def track(event, email, user = nil)
        if user
          add_processed event, email
          log_action user
        else
          add_error event, email
        end
      end

      def add_error(type, email)
        @errors[type] << email unless @errors[type].include? email
      end

      def add_processed(type, email)
        @processed[type] << email unless @processed[type].include? email
      end

      private

      def log_action(user)
        Decidim.traceability.perform_action!(
          "invite",
          user,
          current_user,
          extra: {
            invited_user_role: "participant",
            invited_user_id: user.id
          }
        )
      end
    end
  end
end
