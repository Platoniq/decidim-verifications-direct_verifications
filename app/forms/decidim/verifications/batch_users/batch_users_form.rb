# frozen_string_literal: true

module Decidim
  module Verifications
    module BatchUsers
      # A form object to be used when public users want to get verified by
      # BatchUsers verificator
      class BatchUsersForm < AuthorizationHandler
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
