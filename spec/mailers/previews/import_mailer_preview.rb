# frozen_string_literal: true

module Decidim
  class ImportMailerPreview < ActionMailer::Preview
    def successful_import
      DirectVerifications::ImportMailer.successful_import(User.first)
    end
  end
end
