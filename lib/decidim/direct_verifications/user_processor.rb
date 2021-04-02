# frozen_string_literal: true

require "decidim/direct_verifications/register_user"
require "decidim/direct_verifications/authorize_user"
require "decidim/direct_verifications/revoke_user"
require "decidim/direct_verifications/instrumenter"

module Decidim
  module DirectVerifications
    class UserProcessor
      def initialize(organization, current_user, session, instrumenter)
        @organization = organization
        @current_user = current_user
        @authorization_handler = :direct_verifications

        @emails = {}
        @session = session
        @instrumenter = instrumenter
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
          RegisterUser.new(email, name, organization, current_user, instrumenter).call
        end
      end

      def authorize_users
        emails.each do |email, data|
          AuthorizeUser.new(email, data, session, organization, instrumenter).call
        end
      end

      def revoke_users
        emails.each do |email, _name|
          RevokeUser.new(email, organization, instrumenter).call
        end
      end

      private

      attr_reader :instrumenter
    end
  end
end
