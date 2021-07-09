# frozen_string_literal: true

module Decidim
  module DirectVerifications
    class AuthorizeUser
      # rubocop:disable Metrics/ParameterLists
      def initialize(email, data, session, organization, instrumenter, authorization_handler)
        @email = email
        @data = data
        @session = session
        @organization = organization
        @instrumenter = instrumenter
        @authorization_handler = authorization_handler
      end
      # rubocop:enable Metrics/ParameterLists

      def call
        unless user
          instrumenter.add_error :authorized, email
          return
        end

        return unless valid_authorization?

        Verification::ConfirmUserAuthorization.call(authorization, form, session) do
          on(:ok) do
            instrumenter.add_processed :authorized, email
          end
          on(:invalid) do
            instrumenter.add_error :authorized, email
          end
        end
      end

      private

      attr_reader :email, :data, :session, :organization, :instrumenter, :authorization_handler

      def valid_authorization?
        !authorization.granted? || authorization.expired?
      end

      def user
        @user ||= User.find_by(email: email, decidim_organization_id: organization.id)
      end

      def authorization
        @authorization ||=
          begin
            auth = Authorization.find_or_initialize_by(
              user: user,
              name: authorization_handler
            )
            auth.metadata = data
            auth
          end
      end

      def form
        Verification::DirectVerificationsForm.new(email: user.email, name: user.name)
      end
    end
  end
end
