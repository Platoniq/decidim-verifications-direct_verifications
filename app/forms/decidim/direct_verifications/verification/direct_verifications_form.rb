# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      # A form object to be used when public users want to get verified by
      # DirectVerifications verificator
      class DirectVerificationsForm < AuthorizationHandler
        # This is the input (from the user) to validate against
        attribute :name, String
        attribute :email, String

        # This is the validation to perform
        # If passed, an authorization is created
        validates :email, presence: true
      end
    end
  end
end
