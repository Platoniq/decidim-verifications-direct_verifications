# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      class MetadataEntryParser
        def lines(txt)
          StringIO.new(txt).readlines
        end

        def parse_data(email, line)
          tokens = tokenize(line)

          if tokens[0].chomp == email
            { name: "", type: tokens[1].chomp }
          else
            { name: tokens[0].strip, type: tokens[2].chomp }
          end
        end

        private

        def tokenize(line)
          line.split(",")
        end
      end
    end
  end
end
