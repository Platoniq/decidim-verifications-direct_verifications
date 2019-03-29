# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      # A command to destroy an authorization.
      class DestroyUserAuthorization < Rectify::Command
        # Public: Initializes the command.
        #
        # authorization - The authorization object to destroy.
        def initialize(authorization)
          @authorization = authorization
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the authorization couldn't be destroyed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless authorization

          destroy_authorization
          broadcast(:ok)
        end

        private

        attr_reader :authorization

        def destroy_authorization
          authorization.destroy!
        end
      end
    end
  end
end
