# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      class ConfirmUserAuthorization < Decidim::Verifications::ConfirmUserAuthorization
        def call
          return broadcast(:invalid) unless form.valid?

          authorization.grant!
          broadcast(:ok)
        end
      end
    end
  end
end
