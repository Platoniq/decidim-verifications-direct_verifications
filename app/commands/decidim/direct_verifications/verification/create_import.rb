# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      class CreateImport < Rectify::Command
        def initialize(form)
          @form = form
          @file = form.file
          @organization = form.organization
          @user = form.user
        end

        def call
          return broadcast(:invalid) unless form.valid?

          register_users_async
          broadcast(:ok)
        end

        private

        attr_reader :form, :file, :organization, :user

        def register_users_async
          RegisterUsersJob.perform_later(file.read, organization, user)
        end
      end
    end
  end
end
