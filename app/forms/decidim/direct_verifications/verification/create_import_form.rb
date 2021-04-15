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

        validates :file, :organization, :user, :authorize, presence: true
        validates :authorize, inclusion: { in: ACTIONS.keys }

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
