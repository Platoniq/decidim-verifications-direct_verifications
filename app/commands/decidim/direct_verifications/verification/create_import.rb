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
          @action = form.action
        end

        def call
          return broadcast(:invalid) unless form.valid?

          case action
          when :register
            register_users_async
          when :register_and_authorize
            register_users_async
            file.rewind
            authorize_users_async
          when :revoke
            revoke_users_async
          end

          broadcast(:ok)
        end

        private

        attr_reader :form, :file, :organization, :user, :action

        def register_users_async
          RegisterUsersJob.perform_later(file.path, organization, user)
        end

        def revoke_users_async
          RevokeUsersJob.perform_later(file.path, organization, user)
        end

        def authorize_users_async
          AuthorizeUsersJob.perform_later(file.path, organization, user)
        end
      end
    end
  end
end
