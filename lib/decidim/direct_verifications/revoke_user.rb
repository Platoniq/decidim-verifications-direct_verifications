# frozen_string_literal: true

module Decidim
  module DirectVerifications
    class RevokeUser
      def initialize(email, organization, instrumenter)
        @email = email
        @organization = organization
        @instrumenter = instrumenter
      end

      def call
        unless user
          instrumenter.add_error :revoked, email
          return
        end

        return unless authorization.granted?

        Verification::DestroyUserAuthorization.call(authorization) do
          on(:ok) do
            instrumenter.add_processed :revoked, email
          end
          on(:invalid) do
            add_error :revoked, email
          end
        end
      end

      private

      attr_reader :email, :organization, :instrumenter

      def user
        @user ||= User.find_by(email: email, decidim_organization_id: organization.id)
      end

      def authorization
        @authorization ||= Authorization.find_or_initialize_by(
          user: user,
          name: :direct_verifications
        )
      end
    end
  end
end
