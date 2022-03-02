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
            register_users_async(remove_file: true)
          when :authorize
            authorize_users_async(remove_file: true)
          when :register_and_authorize
            register_users_async
            authorize_users_async(remove_file: true)
          when :revoke
            revoke_users_async(remove_file: true)
          end

          broadcast(:ok)
        end

        private

        attr_reader :form, :file, :organization, :user, :action

        def register_users_async(options = {})
          RegisterUsersJob.perform_later(blob.id, organization, user, form.authorization_handler, options)
        end

        def revoke_users_async(options = {})
          RevokeUsersJob.perform_later(blob.id, organization, user, form.authorization_handler, options)
        end

        def authorize_users_async(options = {})
          AuthorizeUsersJob.perform_later(blob.id, organization, user, form.authorization_handler, options)
        end

        def blob
          @blob ||= ActiveStorage::Blob.create_and_upload!(io: file, filename: secure_name)
        end

        def secure_name
          @secure_name ||= "#{SecureRandom.uuid}#{File.extname(file.tempfile)}"
        end
      end
    end
  end
end
