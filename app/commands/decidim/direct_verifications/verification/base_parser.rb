# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      # Abstract class all concrete parsers should inherit from. They are expected to implement
      # #header, #lines, and #parse_data methods.
      class BaseParser
        EMAIL_REGEXP = /([A-Z0-9+._-]+@[A-Z0-9._-]+\.[A-Z0-9_-]+)\b/i.freeze

        def initialize(txt)
          @txt = txt
          @emails = {}
        end

        def to_h
          lines.each do |line|
            EMAIL_REGEXP.match(line) do |match|
              email = normalize(match[0])
              emails[email] = parse_data(email, line, header)
            end
          end

          emails
        end

        private

        attr_reader :txt, :emails

        def normalize(value)
          value.to_s.downcase
        end
      end
    end
  end
end
