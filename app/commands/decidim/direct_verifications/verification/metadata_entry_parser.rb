# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      class MetadataEntryParser < Parser
        def header
          header_row = lines[0].chomp
          column_names = tokenize(header_row)
          column_names.map(&:to_sym).map(&:downcase)
        end

        def lines
          @lines ||= StringIO.new(txt).readlines
        end

        def parse_data(_email, line, header)
          tokens = tokenize(line)

          hash = {}
          header.each_with_index do |column, index|
            next if email_column?(index)

            hash[column] = tokens[index].strip.chomp
          end
          hash
        end

        private

        def tokenize(line)
          line.split(",")
        end

        def email_column?(index)
          index == 1
        end
      end
    end
  end
end
