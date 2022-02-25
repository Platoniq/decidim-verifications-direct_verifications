# frozen_string_literal: true

require "csv"

module Decidim
  module DirectVerifications
    module Parsers
      class MetadataParser < BaseParser
        I18N_SCOPE = "decidim.direct_verifications.verification.admin.direct_verifications"

        def header
          @header ||= begin
            raise InputParserError, I18n.t("#{I18N_SCOPE}.create.missing_header") if lines.count <= 1

            tokenize(lines[0].chomp).map { |h| h.to_s.downcase }
          end
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
