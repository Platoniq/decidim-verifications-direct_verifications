# frozen_string_literal: true

module Decidim
  module DirectVerifications
    class RegisterUser
      def initialize(email, data, organization, current_user, instrumenter)
        @email = email
        @name = data.is_a?(Hash) ? (data["name"] || data[:name]) : data
        @organization = organization
        @current_user = current_user
        @instrumenter = instrumenter
      end

      def call
        return if user

        InviteUser.call(form) do
          on(:ok) do
            instrumenter.track(:registered, email, user)
          end
          on(:invalid) do
            instrumenter.track(:registered, email)
          end
        end
      rescue StandardError => e
        instrumenter.track(:registered, email)
        raise e if Rails.env.test? || Rails.env.development?
      end

      private

      attr_reader :email, :name, :organization, :current_user, :instrumenter

      def user
        @user ||= User.find_by(email:, decidim_organization_id: organization.id)
      end

      def form
        RegistrationForm.new(
          name: name.presence || fallback_name,
          email: email.downcase,
          organization:,
          admin: false,
          invited_by: current_user,
          invitation_instructions: "direct_invite"
        )
      end

      def fallback_name
        email.split("@").first&.gsub(/\W/, "")
      end
    end
  end
end
