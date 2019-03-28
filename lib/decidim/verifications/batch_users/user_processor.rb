# frozen_string_literal: true

module Decidim
  module Verifications
    module BatchUsers
      class UserProcessor
        def initialize(organization)
          @organization = organization
          @errors = []
          @success = []
        end

        def emails=(emails)
          @emails = emails
        end

        def emails
          @emails || {}
        end

        def errors
          @errors
        end

        def success
          @success
        end

        # def register_users
        # end

        def authorize_users
          @emails.each do |email, name|
            if u = User.find_by(email: email.to_s.downcase, decidim_organization_id: @organization.id)
              Decidim::Verifications::BatchUsers::ConfirmUserEmailAuthorization.call(authorization(u), form(u))
              @success<< email
            else
              @errors<< email
            end
          end
        end

        private

        def authorization(user)
          @authorization = Authorization.find_or_initialize_by(
            user: user,
            name: :batch_users_authorization_handler
          )
        end

        def form(user)
          BatchUsersForm.new(email: user.email, name: user.name)
        end
      end
    end
  end
end