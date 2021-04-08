# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      class CreateImport < Rectify::Command
        def initialize(file, organization, user)
          @file = file
          @organization = organization
          @user = user
        end

        def call
          register_users_async
          broadcast(:ok)
        end

        private

        attr_reader :file, :organization, :user

        def register_users_async
          RegisterUsersJob.perform_later(file.read, organization, user)
        end
      end
    end
  end
end
