# frozen_string_literal: true

module Decidim
  module DirectVerifications
    class RevokeUser
      def initialize(email, organization, instrumenter, authorization_handler)
        @email = email
        @organization = organization
        @instrumenter = instrumenter
        @authorization_handler = authorization_handler
      end

      def call
        unless user
          instrumenter.add_error :revoked, email
          return
        end

        return unless valid_authorization?

        Verification::DestroyUserAuthorization.call(authorization) do
          on(:ok) do
            instrumenter.add_processed :revoked, email
          end
        end
      end

      private

      attr_reader :email, :organization, :instrumenter, :authorization_handler

      def user
        @user ||= User.find_by(email:, decidim_organization_id: organization.id)
      end

      def authorization
        @authorization ||= Authorization.find_by(user:, name: authorization_handler)
      end

      def valid_authorization?
        authorization&.granted?
      end
    end
  end
end
