# frozen_string_literal: true

module Decidim
  module DirectVerifications
    class UserProcessor
      def initialize(organization, current_user)
        @organization = organization
        @current_user = current_user
        @errors = []
        @success = []
        @emails = {}
      end

      attr_reader :organization, :current_user, :errors, :success, :emails

      def emails=(emails)
        @emails = emails.map { |k, v| [k, v || k.split("@").first] }.to_h
      end

      def register_users
        emails.each do |email, name|
          next if find_user(email)
          form = register_form(email, name)
          begin
            InviteUser.call(form) do
              on(:ok) do
                add_success email
              end
              on(:invalid) do
                add_error email
              end
            end
          end
        end
      end

      def authorize_users
        emails.each do |email, _name|
          if (u = find_user(email))
            Verification::ConfirmUserEmailAuthorization.call(authorization(u), authorize_form(u))
            add_success email
          else
            add_error email
          end
        end
      end

      private

      def find_user(email)
        User.find_by(email: email.to_s.downcase, decidim_organization_id: @organization.id)
      end

      def register_form(email, name)
        OpenStruct.new(name: name,
                       email: email.downcase,
                       organization: organization,
                       admin: false,
                       invited_by: current_user,
                       invitation_instructions: "invite_collaborator")
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

      def add_success(email)
        @success << email unless @success.include? email
      end

      def add_error(email)
        @errors << email unless @errors.include? email
      end
    end
  end
end
