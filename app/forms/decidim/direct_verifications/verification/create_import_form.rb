# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      class CreateImportForm < Form
        ACTIONS = {
          "in" => :register,
          "out" => :revoke,
          "check" => :check
        }.freeze

        attribute :file
        attribute :organization, Decidim::Organization
        attribute :user, Decidim::User
        attribute :authorize

        validates :file, :organization, :user, presence: true
        validates :authorize, inclusion: { in: ACTIONS.keys }

        def action
          ACTIONS[authorize]
        end
      end
    end
  end
end
