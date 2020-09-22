# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      class MetadataEntryParser
        def parse_data(email, name, line)
          remainder = line.split(email).last
          { name: name.strip, type: remainder.split(/\s/).last }
        end
      end
    end
  end
end
