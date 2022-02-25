# frozen_string_literal: true

module Decidim
  module DirectVerifications
    class CsvUploader < ApplicationUploader
      # Override the directory where uploaded files will be stored.
      def store_dir
        default_path = "uploads/direct-verifications/"

        return File.join(Decidim.base_uploads_path, default_path) if Decidim.base_uploads_path.present?

        default_path
      end
    end
  end
end
