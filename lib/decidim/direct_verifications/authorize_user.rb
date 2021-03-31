# frozen_string_literal: true

module Decidim
  module DirectVerifications
    class AuthorizeUser
      def initialize(email, data, session, organization, instrumenter)
        @email = email
        @data = data
        @session = session
        @organization = organization
        @instrumenter = instrumenter
      end

      def call
        user = find_user

        unless user
          instrumenter.add_error :authorized, email
          return
        end

        @authorization = find_or_create_authorization(user)
        return unless valid_authorization?

        Verification::ConfirmUserAuthorization.call(authorization, authorize_form(user), session) do
          on(:ok) do
            instrumenter.add_processed :authorized, email
          end
          on(:invalid) do
            instrumenter.add_error :authorized, email
          end
        end
      end

      private

      attr_reader :email, :data, :session, :organization, :instrumenter, :authorization

      def valid_authorization?
        !authorization.granted? || authorization.expired?
      end

      def find_user
        User.find_by(email: email, decidim_organization_id: organization.id)
      end

      def find_or_create_authorization(user)
        auth = Authorization.find_or_initialize_by(
          user: user,
          name: :direct_verifications
        )
        auth.metadata = data
        auth
      end

      def authorize_form(user)
        Verification::DirectVerificationsForm.new(email: user.email, name: user.name)
      end
    end
  end
end
