# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      class CreateImportForm < Form
        ACTIONS = {
          "in" => :authorize,
          "out" => :revoke,
          "check" => :check
        }.freeze

        attribute :file
        attribute :organization, Decidim::Organization
        attribute :user, Decidim::User
        attribute :authorize, String
        attribute :register, Boolean
        attribute :authorization_handler, String

        validates :file, :organization, :user, :authorize, :authorization_handler, presence: true
        validates :authorize, inclusion: { in: ACTIONS.keys }

        validate :available_authorization_handler

        def available_authorization_handler
          return if authorization_handler.in?(organization.available_authorizations)

          errors.add(:authorization_handler, :inclusion)
        end

        def action
          if register && authorize == "in"
            :register_and_authorize
          elsif register
            :register
          else
            ACTIONS[authorize]
          end
        end
      end
    end
  end
end
