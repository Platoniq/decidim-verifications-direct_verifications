# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      class CreateImportForm < Form
        attribute :file

        attribute :organization, Decidim::Organization
        attribute :user, Decidim::User

        validates :file, :organization, :user, presence: true
      end
    end
  end
end
