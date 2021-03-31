# frozen_string_literal: true

module Decidim
  module DirectVerifications
    class RegisterUser

      def initialize(email, name, organization, current_user, instrumenter)
        @email = email
        @name = name
        @organization = organization
        @current_user = current_user
        @instrumenter = instrumenter
      end

      delegate :add_error, :add_processed, :log_action, to: :instrumenter

      def call
        return if find_user(email)

        form = build_form(email, name)
        begin
          InviteUser.call(form) do
            on(:ok) do
              add_processed :registered, email
              log_action find_user(email)
            end
            on(:invalid) do
              add_error :registered, email
            end
          end
        rescue StandardError => e
          add_error :registered, email
          raise e if Rails.env.test? || Rails.env.development?
        end
      end

      private

      attr_reader :email, :name, :organization, :current_user, :instrumenter

      def find_user(email)
        User.find_by(email: email, decidim_organization_id: organization.id)
      end

      def build_form(email, name)
        RegistrationForm.new(
          name: name.presence || fallback_name(email),
          email: email.downcase,
          organization: organization,
          admin: false,
          invited_by: current_user,
          invitation_instructions: "direct_invite"
        )
      end

      def fallback_name(email)
        email.split("@").first
      end
    end
  end
end
