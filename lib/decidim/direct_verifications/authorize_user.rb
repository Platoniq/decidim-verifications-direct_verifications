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

        if user
          auth = authorization(user)
          auth.metadata = data

          return unless !auth.granted? || auth.expired?

          Verification::ConfirmUserAuthorization.call(auth, authorize_form(user), session) do
            on(:ok) do
              instrumenter.add_processed :authorized, email
            end
            on(:invalid) do
              instrumenter.add_error :authorized, email
            end
          end
        else
          instrumenter.add_error :authorized, email
        end
      end

      private

      attr_reader :email, :data, :session, :organization, :instrumenter

      def find_user
        User.find_by(email: email, decidim_organization_id: organization.id)
      end

      def authorization(user)
        Authorization.find_or_initialize_by(
          user: user,
          name: :direct_verifications
        )
      end

      def authorize_form(user)
        Verification::DirectVerificationsForm.new(email: user.email, name: user.name)
      end
    end
  end
end
