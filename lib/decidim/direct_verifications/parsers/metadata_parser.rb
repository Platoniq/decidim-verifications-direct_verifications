# frozen_string_literal: true

require "csv"

module Decidim
  module DirectVerifications
    module Parsers
      class MetadataParser < BaseParser
        I18N_SCOPE = "decidim.direct_verifications.verification.admin.direct_verifications"

        def header
          @header ||= tokenize(lines[0].chomp).to_s.downcase
        end

        def lines
          @lines ||= StringIO.new(txt).readlines
        end

        def parse_data(email, line, header)
          tokens = tokenize(line)

          hash = {}
          header.each_with_index do |column, index|
            next if column.blank?

            value = tokens[index]
            next if value&.include?(email)

            hash[column] = value
          end
          hash
        end

        private

        def tokenize(line)
          CSV.parse_line(line).map do |token|
            token&.strip
          end
        end
      end
    end
  end
end
