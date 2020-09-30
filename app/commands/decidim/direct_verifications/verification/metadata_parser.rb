# frozen_string_literal: true

require "csv"

module Decidim
  module DirectVerifications
    module Verification
      class MetadataParser < BaseParser
        def header
          @header ||= begin
                        header_row = lines[0].chomp
                        column_names = tokenize(header_row)
                        column_names.map(&:to_sym).map(&:downcase)
                      end
        end

        def lines
          @lines ||= StringIO.new(txt).readlines
        end

        def parse_data(email, line, header)
          tokens = tokenize(line)

          hash = {}
          header.each_with_index do |column, index|
            value = tokens[index].strip
            next if value.include?(email)

            hash[column] = value
          end
          hash
        end

        private

        def tokenize(line)
          CSV.parse(line)[0]
        end
      end
    end
  end
end
