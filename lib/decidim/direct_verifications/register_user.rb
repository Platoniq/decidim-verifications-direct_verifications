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

      def call
        return if find_user

        form = build_form

        begin
          InviteUser.call(form) do
            on(:ok) do
              instrumenter.add_processed :registered, email
              instrumenter.log_action find_user
            end
            on(:invalid) do
              instrumenter.add_error :registered, email
            end
          end
        rescue StandardError => e
          instrumenter.add_error :registered, email
          raise e if Rails.env.test? || Rails.env.development?
        end
      end

      private

      attr_reader :email, :name, :organization, :current_user, :instrumenter

      def find_user
        User.find_by(email: email, decidim_organization_id: organization.id)
      end

      def build_form
        RegistrationForm.new(
          name: name.presence || fallback_name,
          email: email.downcase,
          organization: organization,
          admin: false,
          invited_by: current_user,
          invitation_instructions: "direct_invite"
        )
      end

      def fallback_name
        email.split("@").first
      end
    end
  end
end
