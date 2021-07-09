# frozen_string_literal: true

require "csv"

module Decidim
  module DirectVerifications
    module Verification
      class MetadataParser < BaseParser
        def header
          @header ||= begin
                        header_row = lines[0].chomp
                        header_row = tokenize(header_row)
                        normalize_header(header_row)
                      end
        end

        def lines
          @lines ||= StringIO.new(txt).readlines
        end

        def parse_data(email, line, header)
          tokens = tokenize(line)

          hash = {}
          header.each_with_index do |column, index|
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

        def normalize_header(line)
          line.map do |field|
            raise MissingHeaderError if field.nil?

            field.to_sym.downcase
          end
        end
      end
    end
  end
end
