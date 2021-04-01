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
        if (u = find_user)
          auth = authorization(u)
          return unless auth.granted?

          Verification::DestroyUserAuthorization.call(auth) do
            on(:ok) do
              instrumenter.add_processed :revoked, email
            end
            on(:invalid) do
              add_error :revoked, email
            end
          end
        else
          instrumenter.add_error :revoked, email
        end
      end

      private

      attr_reader :email, :organization, :instrumenter

      def find_user
        User.find_by(email: email, decidim_organization_id: organization.id)
      end

      def authorization(user)
        Authorization.find_or_initialize_by(
          user: user,
          name: :direct_verifications
        )
      end
    end
  end
end
