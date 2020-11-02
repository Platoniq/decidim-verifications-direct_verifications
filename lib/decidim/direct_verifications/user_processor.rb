# frozen_string_literal: true

module Decidim
  module DirectVerifications
    class UserProcessor
      def initialize(organization, current_user)
        @organization = organization
        @current_user = current_user
        @authorization_handler = :direct_verifications
        @errors = { registered: [], authorized: [], revoked: [] }
        @processed = { registered: [], authorized: [], revoked: [] }
        @emails = {}
      end

      attr_reader :organization, :current_user, :errors, :processed
      attr_accessor :authorization_handler, :emails

      def register_users
        emails.each do |email, data|
          next if find_user(email)

          name = if data.is_a?(Hash)
                   data[:name]
                 else
                   data
                 end

          form = register_form(email, name)
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
          rescue StandardError
            add_error :registered, email
          end
        end
      end

      def authorize_users
        emails.each do |email, data|
          if (u = find_user(email))
            auth = authorization(u)
            auth.metadata = data

            next unless !auth.granted? || auth.expired?

            Verification::ConfirmUserAuthorization.call(auth, authorize_form(u), session) do
              on(:ok) do
                add_processed :authorized, email
              end
              on(:invalid) do
                add_error :authorized, email
              end
            end
          else
            add_error :authorized, email
          end
        end
      end

      def revoke_users
        emails.each do |email, _name|
          if (u = find_user(email))
            auth = authorization(u)
            next unless auth.granted?

            Verification::DestroyUserAuthorization.call(auth) do
              on(:ok) do
                add_processed :revoked, email
              end
              on(:invalid) do
                add_error :revoked, email
              end
            end
          else
            add_error :revoked, email
          end
        end
      end

      private

      def find_user(email)
        User.find_by(email: email, decidim_organization_id: @organization.id)
      end

      def register_form(email, name)
        OpenStruct.new(name: name.presence || fallback_name(email),
                       email: email.downcase,
                       organization: organization,
                       admin: false,
                       invited_by: current_user,
                       invitation_instructions: "direct_invite")
      end

      def fallback_name(email)
        email.split("@").first
      end

      def authorization(user)
        Authorization.find_or_initialize_by(
          user: user,
          name: authorization_handler
        )
      end

      def authorize_form(user)
        Verification::DirectVerificationsForm.new(email: user.email, name: user.name)
      end

      def add_processed(type, email)
        @processed[type] << email unless @processed[type].include? email
      end

      def add_error(type, email)
        @errors[type] << email unless @errors[type].include? email
      end

      def log_action(user)
        Decidim.traceability.perform_action!(
          "invite",
          user,
          current_user,
          extra: {
            invited_user_role: "participant",
            invited_user_id: user.id
          }
        )
      end
    end
  end
end
